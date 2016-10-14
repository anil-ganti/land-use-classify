function res = land_class(cwd,scene_dir,fname_base,out_dir, class_land)
	class_land = false;
	cheb = false;

	base_dir = cwd;
	data_dir = scene_dir;
	f1 = fullfile(data_dir,out_dir);
	if (exist(f1) == 0)
		mkdir(f1);
	end
	out_dir = strcat(data_dir,out_dir,'/');

	num_bands = 6;

	cat_names = {'heavy_urban', 'light_urban', 'agriculture','woodlot','water'};
	cat_colors = [1 0 0; 1 .5 0; 1 1 0; 0 1 0; 0 0 1;];
	cat_masks = import_masks(data_dir);
	num_cats = size(cat_masks,3);



	b = import_bands(size(cat_masks,1),size(cat_masks,2), num_bands, data_dir,fname_base);

	[mean_sigs,std_devs] = find_mean_sigs(b, cat_masks);
	disp(mean_sigs);
	disp(std_devs);

	plot_mean_sigs(cat_names, cat_colors, mean_sigs,std_devs, strcat(out_dir,'signatures.png'))

	if class_land
		if cheb
			distances = calc_distances(b, cat_masks, mean_sigs,false);
		else
			distances = calc_distances(b, cat_masks, mean_sigs,true);
		end

		index = find_mins(distances);

		im = create_rgb(index, b);

		dlmwrite(index, strcat(out_dir,'indices.txt'))
		imwrite(im, strcat(out_dir,'classification.tif'));
	end

	res = 1;
end

function [] = plot_mean_sigs(cat_names, cat_colors, mean_sigs,std_devs,filename)
	disp(sprintf('Saving mean signatures to %s',filename))
	figure
	hold on;
	for i=1:length(cat_names)
		errorbar(1:6, mean_sigs(i,:), std_devs(i,:),'Color',cat_colors(i,:))
	end
	hold off;
	print(filename, '-dpng')
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

function distances = calc_distances(bands, cat_masks, mean_sigs,eucl)
	b = bands;
	num_cats = size(cat_masks,3);
	distances = zeros(size(b,1),size(b,2),num_cats);
	for i=1:num_cats
		sig = permute(mean_sigs(i,:),[3,1,2]);
		sig_mat = repmat(sig, [size(b,1),size(b,2),1]);
		if eucl
			norm2 = sum((sig_mat - b).^2,3);
		else
			norm2 = max(sig_mat-b,[],3);
		end
		distances(:,:,i) = norm2;
	end
end

function bands = import_bands(xlen,ylen,num_bands,data_dir, fname_base)
	bands= zeros(xlen, ylen, num_bands);
	for i=1:num_bands
		b_file = strcat(...
			data_dir,fname_base,'_sr_band',num2str(i),'.tif');
		disp(sprintf('reading in %s', b_file));
		bands(:,:,i) = imread(b_file);
	end
end

function cat_masks = import_masks(data_dir)
	hu_mask = imread(strcat(data_dir,'heavy_urban.tif'));
	lu_mask = imread(strcat(data_dir,'light_urban.tif'));
	ag_mask = imread(strcat(data_dir,'agriculture.tif'));
	wl_mask = imread(strcat(data_dir,'woodlot.tif'));
	wr_mask = imread(strcat(data_dir,'water.tif'));
	
	cat_masks = cat(3, hu_mask, lu_mask, ag_mask,wl_mask,wr_mask);
end

function [sigs,devs] = find_mean_sigs(im_bands, cat_masks)
	num_cats = size(cat_masks,3);
	num_bands = size(im_bands,3);
	
	sigs = zeros(num_cats,num_bands);
	devs = zeros(num_cats,num_bands);
	% generate mean reference signature
	for i=1:num_cats
		fprintf('Processing category %d\n',i)
		mask = cat_masks(:,:,i);
		if sum(sum(mask)) == 0
			fprintf('Warning: mask for this category is all zeros!')
		end
		sig = zeros(1,num_bands);
		dev = zeros(1,num_bands);
		for j=1:num_bands
			fprintf('Processing band %d\n', j)
			[sig(j),dev(j)] = find_mean_sig(im_bands(:,:,j), mask);
		end
		sigs(i,:) = sig;
		devs(i,:) = dev;
	end

end

function [sig,dev] = find_mean_sig(im, mask)
	tmp = im(mask>0);
	if min(tmp) < 0
		disp('Warning: received signals less than zero!')
		disp(min(tmp))
	end
	sig = mean(tmp);
	dev = std(tmp);
end
