%SCATTERGRAM A time-frequency representation of scattering coefficients
%   [scatt1_image,scatt2_image,scatt1s_image] = scattergram(x,options,bands)
%   calculates the first- and second-order scattering coefficients of x 
%   using the parameters in options and displays their temporal evolution. For
%   first-order coefficients, this is done by plotting the scattering 
%   coefficients with respect to j_1 and time. The second-order coefficients 
%   are shown with respect to j_2 and time for a fixed j_1. This j_1 is chosen
%   by selecting the appropriate band in the first-order display. Initially, 
%   it is set to the value in the bands parameter, or, if missing, to the 
%   highest frequency. Both displays are plotted on a log-frequency scale and
%   the amplitudes are processed using a logarithm to compress their range 
%   before display.
%
%   The following options can be specified
%      options.frequency_points - The number of rendering points in the
%         frequency dimension with which to interpolate. [default 128]
%      options.time_points - The number of rendering points in the time
%         dimension. [default 4*length(x)/options.frequency_points].
%      options.second_order_displays - The number of second-order displays
%         to render. If more than 1, the correspond j_1 for each display
%         can be changed by selecting the display prior to selecting the band
%         in the first-order display. [default 1]
%      options.normalize_display - If 1, normalize the display according to
%         the L1 norm of the filter in the frequency domain. This yields a
%         plot for a constant spectral distribution. [default 1]
%      options.log_threshold - A vector containing the threshold for the 
%         logarithm compression in the first- and second orders.
%         [default [1e-2 1e-3]]
%      options.no_labels - If 1, removes the labels and titles in the display
%         [default 0]

% Copyright 2012, CMAP, Ecole Polytechnique
% Contributors: Joakim Andén
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software.  You can  use, 
% modify and/ or redistribute the software under the terms of the CeCILL
% license as circulated by CEA, CNRS and INRIA at the following URL
% "http://www.cecill.info". 
%
% The fact that you are presently reading this means that you have had
% knowledge of the CeCILL license and that you accept its terms.

function [scatt1_image,scatt2_image] = scattergram(x,options,bands)
	if ~isfield(options,'frequency_points'), options.frequency_points = 128; end
	if ~isfield(options,'time_points'), options.time_points = 4*length(x)/options.frequency_points; end
	if ~isfield(options,'second_order_displays'), options.second_order_displays = 1; end
	if ~isfield(options,'normalize_display'), options.normalize_display = 1; end
	if ~isfield(options,'log_threshold'), options.log_threshold = [1e-2 1e-3]; end
	if ~isfield(options,'no_labels'), options.no_labels = 0; end
		
	if nargin < 3
		bands = [];
	end
		
	totsub = 1+options.second_order_displays;
	
	if ~isfield(options.filters,'P')
		options.filters = 0;
	end
	
	[out,meta] = scatt(x,options);
	
	% to account for differing order numberings (0-based or 1-based)
	if min(meta.order) > 0
		meta.order = meta.order-min(meta.order);
	end

	if options.normalize_display
		max_scales = max([options.filters.J]+[options.filters.P]);
	
		nrm = ones(size(meta.scale));
		for k = 1:length(meta.scale)
			if meta.order(k)==0
				continue;
			end
			for m = 1:meta.order(k)
				sc = mod(floor(meta.scale(k)/max_scales^(meta.order(k)-m)),max_scales);
				nrm(k) = nrm(k)*norm(options.filters.psi{1}{sc+1}{1},2);
			end
		end
	
		out = bsxfun(@times,out,1./nrm);
	end

	[scatt1_image,pI_1] = scatt_image(out,options,meta,1);
	scatt2_image = scatt_image(out,options,meta,2);
	
	image_process1 = @(im)(log10(abs(im)+options.log_threshold(1)));
	
	image_process2 = @(im)(log10(abs(im)+options.log_threshold(2)));
	
	subct = 0;
	
	subplot(totsub,1,subct+1); subct = subct+1;
	imagesc(image_process1(scatt1_image));
	set(gca,'YDir','normal');
	set(gca,'YTick',[]);
	set(gca,'XTick',[]);
	if ~options.no_labels
		ylabel('log(\omega_1)');
		xlabel('t');
		title('First-order windowed scattering (large scale)');
	end
	colormap('jet');
	
	c_max = -Inf;
	for k = 1:length(scatt2_image)
		c_max = max(c_max,max(scatt2_image{k}(:)));
	end
	
	for k = 1:options.second_order_displays
		bandk = 1;
		if length(bands) >= k, bandk = bands(k); end
		subplot(totsub,1,subct+1); subct = subct+1;
		imagesc(image_process2(scatt2_image{bandk}));
		set(gca,'CLim',[image_process2(0) image_process2(c_max)]);
		set(gca,'YDir','normal');
		set(gca,'YTick',[]);
		set(gca,'XTick',[]);
		set(gca,'Userdata',{scatt2_image image_process2 k==1 pI_1});
		
		if ~options.no_labels
			ylabel('log(\omega_2)');
			xlabel('t');
			title(sprintf('Second-order windowed scattering (large scale) Band #%2d',bandk));
		end
		colormap('jet');
	end
	
	dcm = datacursormode;
	dcm.UpdateFcn = @custom_update;
end

function txt = custom_update(~,event)
	pos = get(event,'Position');
	CData = get(get(event,'Target'),'CData');
	txt = {['X: ',num2str(pos(1),4)],...
	    ['Y: ',num2str(pos(2),4)],...
	    ['Index: ',num2str(CData(pos(2),pos(1)),4)]};
	
	if ~isempty(get(get(get(event,'Target'),'Parent'),'UserData'))
		userdata = get(get(get(event,'Target'),'Parent'),'UserData');
		userdata{3} = userdata{3}+1;
		set(get(get(event,'Target'),'Parent'),'Userdata',userdata);
		return;
	end
	
	papa = get(get(get(event,'Target'),'Parent'),'Parent');
	
	childs = get(papa,'Children');
	
	k0 = 0;
	mx = 0;
	for k = 1:length(childs)
		userdata = get(childs(k),'UserData');
		if ~isempty(userdata) && userdata{3} > mx
			mx = userdata{3};
			k0 = k;
		end
	end
	
	userdata = get(childs(k0),'UserData');
	
	pI_1 = userdata{end};
	
	j1 = pI_1(pos(2));
	
	txt = [txt ['Band #' sprintf('%d',j1)]];
	
	titl = get(get(childs(k0),'Title'),'String');
	if ~isempty(titl)
		titl = [titl(1:find(titl=='B',1,'last')-1) txt{end}];
		title(childs(k0),titl);
	end
	
	grandkids = get(childs(k0),'Children');
	
	set(grandkids(1),'CData',userdata{2}(userdata{1}{j1}));
end

function last_axes_down(target,event)
	userdata = get(target,'UserData');
	
	if userdata{3} == 1
		set(target,'CData',userdata{2});
		userdata{3} = 2;
	else
		set(target,'CData',userdata{1});
		userdata{3} = 1;
	end
	set(target,'UserData',userdata);
end

function [im,pI_1,pI_2] = scatt_image(out,options,meta,q)
	scale = meta.scale;
	
	filter_ct = max([options.filters.J]+[options.filters.P]);
	
	mu = calc_mu(options.filters);
	
	which_filter = @(xi)(length(mu)+1-find(cumsum(mu(end:-1:1))>=xi,1));
	
	count = zeros(1,length(options.filters.psi{1}));
	
	for k = 1:length(options.filters.psi{1})
		count(k) = sum(meta.order==2&floor(scale/filter_ct)==k-1);
	end	
	
	axis = @(xi,mx)(exp((xi-1)*log(mx))*mx);
	
	sr = 64;
	
	fI = axis([0:options.frequency_points-1]/options.frequency_points,sr)/sr;
	
	fI_1 = zeros(size(fI));
	for k = 1:length(fI)
		fI_1(k) = which_filter(fI(k));
	end
	
	pI_1 = zeros(size(fI));
	
	for k = 1:length(fI)
		pI_1(k) = find(meta.order==1&scale==fI_1(k)-1);
	end
	
	tI = 1+floor([0:options.time_points-1]/options.time_points*size(out,1));	
	
	if q == 1
		im = zeros(length(fI),length(tI));
		for k = 1:length(tI)
			im(:,k) = out(tI(k),pI_1);
		end
		return;
	end
	
	mu2 = calc_mu(options.filters);
	
	nf0 = length(mu2);
	
	mu2 = mu2(end-max(count)+1:end);
	mu2 = mu2/sum(mu2);
	
	sr = (mu2(end))^(1/(-options.frequency_points+1));
	
	fI = [0:options.frequency_points-1]/options.frequency_points;
	fI = (1/mu2(end)).^(-(fI-1)/(1/options.frequency_points-1));
	
	which_2nd_filter = @(xi)(nf0+1-find(cumsum(mu2(end:-1:1))>=xi,1));
	
	fI_2 = zeros(size(fI));
	for k = 1:length(fI)
		fI_2(k) = which_2nd_filter(fI(k));
	end
	
	pI_2 = {};
	for n = 1:length(count)
		pI_2{n} = zeros(size(fI));
		for k = 1:length(fI)
			p = find(meta.order==2& ...
				floor(scale/filter_ct)==n-1& ...
				mod(scale,filter_ct)==fI_2(k)-1);
			if ~isempty(p)
				pI_2{n}(k) = p;
			end
		end
		
		im{n} = zeros(length(fI),length(tI));
		
		for k = 1:length(tI)
			im{n}(pI_2{n}~=0,k) = out(tI(k),pI_2{n}(pI_2{n}~=0));
		end
	end
end

function mu = calc_mu(filters)
	f = get_bank(filters);
	
	[~,I] = max(f.');
	clear f;
	
	I = I(2:end/2+1);
	
	mu = zeros(1,length(filters.psi{1}));
	
	for k = 1:length(filters.psi{1})
		mu(k) = sum(I==k)/length(I);
	end
	
	mu = mu(end:-1:1);
end

function f = get_bank(filters)
	f = zeros(length(filters.phi{1}),length(filters.psi{1}));
	for k = 1:length(filters.psi{1}), f(:,k) = filters.psi{1}{end+1-k}{1}; end
end