function status = gen_study_mask(im_path,polys_path,mask_path,n,s,e,w)
% gen_study_mask('data/016035/2016239/LC80160352016239LGN00_sr_band1.tif','masks/i85.ref','test_mask.tif',37.100372,34.963182,-77.951982, 80.532238)
	cwd = pwd;
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
	xv = polys(1).xv;
	yv = polys(1).yv;
	road = cat(1,xv,yv)';

	% calculate the first and last points within the img field
	for i=1:size(road,1)
		if road(i,2) < n & road(i,2) > s & road(i,1) > w & road(i,1) < e
			rstart = road(max(i-1,1),:)
			break
		end
	end

	for i=size(road,1):-1:1
		if road(i,2) < n & road(i,2) > s & road(i,1) > w & road(i,1) < e
			rend = road(min(i+1,size(road,1)),:)
			break
		end
	end

	% create polygon around road
	corridor = zeros(4,2);

	whos road

	rot_r = [0 -1; 1 0];
	rot_l = [0 1; -1 0];

	tang = rend - rstart
	tang = tang'/norm(tang)
	norm_r = rot_r*tang
	norm_l = rot_l*tang

	corridor(1,:) = rstart' + .5*norm_r;
	corridor(2,:) = rstart' + .5*norm_l;
	corridor(4,:) = rend' + .5*norm_r;
	corridor(3,:) = rend' + .5*norm_l

	mask = zeros(size(im));
	disp('Calculating mask')
	whos corridor
	in = inpolygon(x,y,corridor(:,1),corridor(:,2));
	mask(in) = 1;
	imwrite(mask, mask_path);
	status = 1;
end