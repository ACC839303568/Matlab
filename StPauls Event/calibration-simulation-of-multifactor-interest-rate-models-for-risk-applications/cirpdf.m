function PDF = cirpdf(r,a, b, sigma, dt, r0)
% CIRPDF Compute PDF of CIR transition density

c = 4*a/(sigma^2*(1 - exp(-a*dt)));
k = 4*b*a/sigma^2;
lambda =  c*r0*exp(-a*dt);
PDF = c*ncx2pdf(c*r,k,lambda);