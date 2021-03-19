function ImScrambled = ScrumbleImage(imdata)
    ImSize = size(imdata);
    RandomPhase = angle(fft2(rand(ImSize(1), ImSize(2))));
    ImFourier = fft2(imdata);       
    Amp = abs(ImFourier);  
    Phase = angle(ImFourier) + RandomPhase;   
    ImScrambled = real(ifft2(Amp.*exp(sqrt(-1)*(Phase))));
end