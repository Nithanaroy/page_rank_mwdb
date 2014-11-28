function [ y ] = gaussf( x )
%GAUSSMF gaussian function in task 1(b)
mu = 0;
sigma = 0.25;
y = 1./(sigma.*sqrt(2.*pi)).*exp(-0.5.*((x-mu)./sigma).^2); 
end