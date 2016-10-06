function status = landsat()
	polys_path='~/Documents/cee_675/coords.txt';
	mask_path = '~/Documents/cee_675/015035/2016264/hu.tif'
	im = imread('~/Documents/cee_675/015035/2016264/LC80150352016264LGN00_sr_band1.tif');
	w=-79.075375;
    e=-76.392312;
    n=37.141384;
    s=34.923864;

	generate_reference_mask(im,n,s,e,w,polys_path, mask_path);

	status = 1;
end


function [] = generate_reference_mask(im,n,s,e,w,polys_path, mask_path)
	
	polys = read_polys(polys_path);

	xrange = linspace(w,e,size(im,2));
	yrange = linspace(n,s,size(im,1));

	[x,y] = meshgrid(xrange,yrange);

	for i=1:length(polys)
		mask = zeros(size(im));
		mask(inpolygon(x,y,polys(i).xv,polys(i).yv)) = 1;
	end

	imwrite(mask, mask_path);
end

function polys = read_polys(polys_path)
	fid = fopen(polys_path, 'r');

	i=1;
	tline = fgetl(fid);
	while ischar(tline)
		disp(tline);
		delim = find(tline==';');
		xv = str2num(tline(1:delim-1));
		yv = str2num(tline(delim+1:end));
		polys(i).xv = xv;
		polys(i).yv = yv;
		i=i+1;
		tline = fgetl(fid);
	end
	fclose(fid);

	disp(polys);
end