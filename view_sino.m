% View a saved sinogram from 3 different directions

figure(1)
montage(sinogram,"BorderSize",1,"BackgroundColor",'w')

permutation = permute(sinogram,[1 3 2]);

figure(2)
montage(permutation,"BorderSize",1,"BackgroundColor",'w')

permutation2 = permute(sinogram,[2 3 1]);

figure(3)
montage(permutation2,"BorderSize",1,"BackgroundColor",'w')

