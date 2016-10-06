function im = land_class(rowpath, scenedate)
	if false
		test_mean_sigs()
		im = 0;
	else
		base_dir = pwd;
		data_dir = strcat(base_dir,'/data/',rowpath,'/',scenedate,'/');

		num_bands = 6;

		cat_masks = import_masks(data_dir);
		num_cats = size(cat_masks,3);

		b = import_bands(size(cat_masks,1), ...
			size(cat_masks,2), num_bands, data_dir,rowpath,scenedate);

		mean_sigs = find_mean_sigs(b, cat_masks);
		disp(mean_sigs);

		distances = calc_distances(b, cat_masks, mean_sigs);

		index = find_mins(distances);

		im = create_rgb(index, b);
	end
end

function [] = test_mean_sigs()
	mask = eye(4);

	sig = 5*ones(4,4);
	sig = sig + 2*(1-eye(4));

	m_sig = find_mean_sig(sig,mask);

	assert(m_sig==5)

	masks = cat(3,mask,mask,mask);

	im = 5 * ones(4,4);
	im = im + 2*(1-eye(4));
	ims = cat(3,im,im,im,im);
imsho
	m_sigs = find_mean_sigs(ims, masks);

	whos ims
	whos masks
	whos m_sigs
	disp(m_sigs)
	calc_distances(ims, masks, m_sigs)
end

function im = create_rgb(index,bands)
	r = zeros(size(index));
	g = zeros(size(index));
	b = zeros(size(index));

	% heavy urban - red
	r(index==1 & bands(:,:,1)>0)=1;

	% light urban - orange
	r(index==2 & bands(:,:,1)>0)=1;
	g(index==2 & bands(:,:,1)>0)=.5;
	
	%  agriculture - yellow
	r(index==3 & bands(:,:,1)>0)=1;
	g(index==3 & bands(:,:,1)>0)=1;

	% woodlot - green
	g(index==4 & bands(:,:,1)>0)=1;

	% water - blue
	b(index==5 & bands(:,:,1)>0)=1;

	sum(sum(r))
	sum(sum(g))
	sum(sum(b))
	im = cat(3,r,g,b);
end

function classes = find_mins(distances)
	[vals,classes] = min(distances,[],3);
end

function distances = calc_distances(bands, cat_masks, mean_sigs)
	b = bands;
	num_cats = size(cat_masks,3);
	distances = zeros(size(b,1),size(b,2),num_cats);
	for i=1:num_cats
		sig = permute(mean_sigs(i,:),[3,1,2]);
		sig_mat = repmat(sig, [size(b,1),size(b,2),1]);
		norm2 = sum((sig_mat - b).^2,3);
		distances(:,:,i) = norm2;
	end
end

function bands = import_bands(xlen,ylen,num_bands,base_dir,rowpath,scenedate)
	bands= zeros(xlen, ylen, num_bands);
	for i=1:num_bands
		b_file = strcat(...
			base_dir,'LC8',rowpath,scenedate,'LGN00_sr_band',num2str(i),'.tif');
		disp(sprintf('reading in %s', b_file));
		bands(:,:,i) = imread(b_file);
	end
end

function cat_masks = import_masks(base_dir)
	hu_mask = imread(strcat(base_dir,'heavy_urban.tif'));
	lu_mask = imread(strcat(base_dir,'light_urban.tif'));
	ag_mask = imread(strcat(base_dir,'agriculture.tif'));
	wl_mask = imread(strcat(base_dir,'woodlot.tif'));
	wr_mask = imread(strcat(base_dir,'water.tif'));
	
	cat_masks = cat(3, hu_mask, lu_mask, ag_mask,wl_mask,wr_mask);
end

function sigs = find_mean_sigs(im_bands, cat_masks)
	num_cats = size(cat_masks,3);
	num_bands = size(im_bands,3);
	
	sigs = zeros(num_cats,num_bands);

	% generate mean reference signature
	for i=1:num_cats
		mask = cat_masks(:,:,i);
		if sum(sum(mask)) == 0
			disp('Warning: mask for this category is all zeros!')
		end
		sig = zeros(1,num_bands);
		for j=1:num_bands
			sig(j) = find_mean_sig(im_bands(:,:,j), mask);
		end
		sigs(i,:) = sig;
	end

end

function sig = find_mean_sig(im, mask)
	tmp = im(mask>0);
	sig = mean(tmp);
end
