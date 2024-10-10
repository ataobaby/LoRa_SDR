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
    'GainSource','AGC Fast Attack',...
    'SamplesPerFrame',4e6,'Gain',60);  

%% Transmit Signal
for num = 1:10
    signalIQ = LoRa_Tx(char(num+47),BW,SF,Power,Fs,0); 
    signalIQ = conj(signalIQ);
    Tdata(:,num) =[zeros(ceil(length(signalIQ)*0.1),1);signalIQ;zeros(length(signalIQ)*1,1)];
end
upChirp = conj(signalIQ(1:10240/5));
%% 发射流程
SendIndex = 1;
baseBandData = [];
while 1
    tx(Tdata(:,SendIndex));
    disp('ping');
    k =  0;
    while 1
        k = k+1;
        Rdata = rx();
        signalIndex = signalCapture(Rdata,upChirp,10,0);
        if signalIndex ~= -1 && signalIndex + 61951 <= 4e6
            numStr = LoRa_Rx(Rdata(signalIndex:signalIndex+61951),BW,SF,2,Fs,0);
            disp('pong');
            if numStr>96 && numStr <107
                disp(char(numStr));
                Data = [numStr;Rdata(signalIndex:signalIndex+61951)];
                baseBandData = [baseBandData,Data];
                if numStr == 96 + SendIndex
                    SendIndex = mod(numStr-96, 10)+1;
                    break;
                end
            end
        elseif k >= 2
            break;
        end
    end
end