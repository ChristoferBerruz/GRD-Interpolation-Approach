function A = getCircles(filename)
    %Default is assumed that delimiter is a space
    fileID = fopen(filename, 'r');
    formatSpec = '%f %f %f %f %f';
    A = textscan(fileID, formatSpec);
    fclose(fileID);
    A =  A';
end