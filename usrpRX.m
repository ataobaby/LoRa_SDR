clear,clc;

%% 配置参数
SF = 10;  %扩频因子
BW = 500e3; %带宽
fc = 433e6; %发射频段
Power = 14; %功率

Fs = 1e6 ;
tx = sdrtx('Pluto','RadioID','usb:0','CenterFrequency',fc,...
    'BasebandSampleRate',Fs,...
    'Gain',0);
rx = sdrrx('Pluto','RadioID','usb:0','CenterFrequency',fc,...
    'BasebandSampleRate',Fs,...
    'OutputDataType','double',...
    'GainSource','AGC Fast Attack', ...
    'SamplesPerFrame',2e6,'Gain',60);    
%% Transmit Signal
for num = 1:10
    signalIQ = LoRa_Tx(char(num+96),BW,SF,Power,Fs,0); 
    Tdata(:,num) =[zeros(length(signalIQ ),1);signalIQ ];
end
upChirp = conj(signalIQ(1:10240/5));
%% 发射流程
SendIndex = 1;
baseBandData = [];
while 1
    k =  0;
    while 1
        k = k+1;
        Rdata = rx();
%         figure(1)
%         plot(abs(Rdata));
%         spectrogram(Rdata,300,0,500,Fs,'yaxis','centered');
        signalIndex = signalCapture(Rdata,upChirp,8,0);
        if signalIndex ~= -1 && signalIndex+61951 <= 4e6
            numStr = LoRa_Rx(conj(Rdata(signalIndex:min([signalIndex+61951,4e6]))),BW,SF,2,Fs,0);
            if numStr>47 && numStr<58
                disp('ping')
                disp(char(numStr));
                Data = [numStr;Rdata(signalIndex:min([signalIndex+61951,4e6]))];
                SendIndex = numStr - 47;
                baseBandData = [baseBandData,Data];
%                 release(rx);
                break;
            end
        end
    end
    disp('pong');
    tx(Tdata(:,SendIndex));
%     release(tx);
end
