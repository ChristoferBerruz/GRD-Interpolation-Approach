function res = gensphere(circles, v, f)

     % eliminate circles with invalid (or nearly 0) angles
     mask = find(abs(circles{4}) < 0.99999);

     x = circles{1}(mask);
     y = circles{2}(mask);
     z = circles{3}(mask);  
     eta = circles{4}(mask);
     dEtaSq = circles{5}(mask);

     % make sure all circle centers are unit vectors,
     % to correct any errors caused by limited-precision
     % printing
     center_c = [x y z];
     center_c = center_c ./ sqrt(sum(center_c.^2,2));

     % get actual opening angle and its variance
     alpha   = acos(eta);
     sigmasq = dEtaSq./(1 - eta.^2);
     
     % intensity profile used for one circle
     fun = @(t, alpha, sigmasq) 1./sqrt((2*pi*sigmasq)).*exp(-(t - alpha).^2./(2*sigmasq));

     % Compute weighted sum of intensities in each patch on the circle

     nCircles = length(alpha);
     totalVal = zeros(length(f), 1);
     for j = 1:nCircles        % to sample, use "j = randperm(nCircles, samplesize)"
       % normalize intensity for this circle so it sums to 1 over sphere
       R = 1./(2*pi*integral(@(t) fun(t, alpha(j), sigmasq(j)).*sin(t), 0, pi));

       % For each face, evaluate function values at vertices and average;
       % multiply by by area of patch to get approximate integral
       angle = abs(acos(v * center_c(j,:)'));
       vval = R * fun(angle, alpha(j), sigmasq(j));
       fval = mean(vval(f), 2) * (4 * pi^2 / length(f));

       totalVal = totalVal + fval;
     end
     
     % draw the sphere colored according to the intensity data
     figure
     patch('Vertices', v, 'Faces', f, 'FaceVertexCData', totalVal, 'FaceColor', 'flat', 'EdgeColor', 'none');
     rotate3d on;
     pbaspect([1 1 1]);
     view([0 -90]); % view centered on south pole

     % return the spherical coords of the center of the patch with max intensity
     [~, i] = max(totalVal);
     c = mean(v(f(i,:), :));
     c = num2cell(c ./ sqrt(sum(c .* c)));
     [az el r] = cart2sph(c{:});
     res = rad2deg([el, az])
end