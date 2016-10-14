function [] = class_change(old_im,new_im)
% ,old_n,old_s,old_e,old_w,new_n,new_s,new_e,new_w
%  class_change('data/016035/2014361/indices.tif','data/016035/2016031/indices.tif')
	disp(sprintf('reading in %s', old_im))
	old = imread(old_im);
	disp(sprintf('reading in %s', new_im))
	new = imread(new_im);

	whos old
	whos new

	xdim = min(size(old,1),size(new,1));
	ydim = min(size(old,2),size(new,2));

	delta = zeros(xdim,ydim);
	old = old(1:xdim,1:ydim);
	new = new(1:xdim,1:ydim);
	whos delta
	whos old
	whos new

	sum(old(:) == 1)

	delta= new - old;
	

	%im = create_rgb(delta);
	%imshow(im)
end

function im = create_rgb(delta)
	r = zeros(size(delta));
	g = zeros(size(delta));
	b = zeros(size(delta));

	% +1 developed - orange
	r(delta==1)=1;
	g(delta==1)=.5;

	sum(sum(r))

	% +2 developed - red
	r(delta==2)=1;

	% -1 developed - green
	g(delta==-1)=1;

	% -2 developed - blue
	b(delta==-2)=1;

	% no change
	r(delta==0)=1;
	g(delta==0)=1;
	b(delta==0)=1;

	im = cat(3,r,g,b);
end