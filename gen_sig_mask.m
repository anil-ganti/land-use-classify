function status = generate_reference_mask(im_path,polys_path,mask_path,n,s,e,w)
	
	polys = read_polys(polys_path);
	im = imread(im_path);

	if ischar(n)
		n=str2double(n);
	end
	if ischar(s)
		s=str2double(s);
	end
	if ischar(e)
		e=str2double(e);
	end
	if ischar(w)
		w=str2double(w);
	end

	xrange = linspace(w,e,size(im,2));
	yrange = linspace(n,s,size(im,1));

	[x,y] = meshgrid(xrange,yrange);

	disp(sprintf('N: %d S: %d E: %d W: %d', n,s,e,w))
	mask = zeros(size(im));
	for i=1:length(polys)
		pol = polys(i);
		%txv = [xrange(1) xrange(1) xrange(1000) xrange(1000)]
		%tyv = [yrange(1) yrange(1000) yrange(1000) yrange(1)]
		%in = inpolygon(x,y,txv,tyv);
		in = inpolygon(x,y,pol.xv,pol.yv);
		mask(in) = 1;
	end

	disp(sprintf('Total sum in %s:%d',mask_path,sum(sum(mask))))
	imwrite(mask, mask_path);

	status = 1;
end