function y = randombits(SF)
y = dec2bin(floor(2^SF*rand));
length_y = length(y);
if length_y < SF
    y = [repmat('0', 1, SF-length_y),y];
end