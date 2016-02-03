matred = uint8(zeros(2,2,3));
matred(:,:,1) = mat(:,:,1);
matgreen = uint8(zeros(2,2,3));
matgreen(:,:,2) = mat(:,:,2);
matblue = uint8(zeros(2,2,3));
matblue(:,:,3) = mat(:,:,3);
subplot(2,2,1)
image(mat)
subplot(2,2,2)
image(matred)
subplot(2,2,3)
image(matgreen)
subplot(2,2,4)
image(matblue)
