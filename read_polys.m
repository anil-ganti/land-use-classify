function polys = read_polys(polys_path)
	fid = fopen(polys_path, 'r');
	i=1;
	tline = fgetl(fid);
	while ischar(tline)
		delim = find(tline==';');
		xv = str2num(tline(1:delim-1));
		yv = str2num(tline(delim+1:end));
		polys(i).xv = xv;
		polys(i).yv = yv;
		i=i+1;
		tline = fgetl(fid);
	end
	fclose(fid);
end