clear,clc;

%% 配置参数
SF = 10;  %扩频因子
BW = 500e3; %带宽
fc = 915e6; %发射频段
Power = 14; %功率

Fs = 5e6 ;
tx = sdrtx('Pluto','RadioID','usb:0','CenterFrequency',fc,...
    'BasebandSampleRate',Fs,...
    'SamplesPerFrame',2e6,'Gain',0);
rx = sdrrx('Pluto','RadioID','usb:0','CenterFrequency',fc,...
    'BasebandSampleRate',Fs,...
    'OutputDataType','double',...
    'SamplesPerFrame',2e6,'Gain',60);    
%% Transmit Signal
for num = 1:10
    signalIQ = LoRa_Tx(char(num+96),BW,SF,Power,Fs,0); 
    Tdata(:,num) =[zeros(length(signalIQ ),1);signalIQ ];
end
upChirp = signalIQ(1:10240);
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
        figure(1);
        plot(abs(Rdata))
        signalIndex = signalCapture(Rdata,upChirp,8,0);
        if signalIndex ~= -1 && signalIndex+309759 <= 2e6
            numStr = LoRa_Rx(Rdata(signalIndex:min([signalIndex+309759,2e6])),BW,SF,2,Fs,0);
            if numStr>47 && numStr<58
                disp('pong');
                disp(char(numStr));
                Data = [numStr;Rdata(signalIndex:min([signalIndex+309759,2e6]))];
                SendIndex = mod(numStr - 47, 10)+1;
                baseBandData = [baseBandData,Data];
                break;
            end
        elseif k == 20
            break;
        end
    end
end
release(tx);
release(rx);