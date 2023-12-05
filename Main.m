%首先产生一串二进制序列
signal=randi([0 1],1,20);
signal
signal1=zeros(1,10);
signal2=zeros(1,10);
SNR=15;
%要实现串并变换，即输出两路信号
for i=1:10
signal1(1,i)=signal(1,2*i-1);
signal2(1,i)=signal(1,2*i);
end
signal1
signal2
temp1=zeros(1,2);
temp2=zeros(1,2);
QAM_Pre1=zeros(1,5);
QAM_Pre2=zeros(1,5);
fs=1000;
%N去大于5000的2的整数次幂
N=8192;
%为了实现8-PAM调制，需要把3个比特“翻译”成一个数值
for i=1:10
   if(mod(i,2)~=0)
     temp1(1,1)=signal1(1,i);
     temp2(1,1)=signal2(1,i);
   end
   if(mod(i,2)==0)
        temp1(1,2)=signal1(1,i);
        temp2(1,2)=signal2(1,i);
        %transfer into decimal
        QAM_Pre1(1,(i/2))=2*temp1(1,1)+temp1(1,2);
        QAM_Pre2(1,(i/2))=2*temp2(1,1)+temp2(1,2);
   end
end
QAM_Pre1=2*QAM_Pre1-3;
QAM_Pre2=2*QAM_Pre2-3;
QAM_Pre1
QAM_Pre2
%PAM_Pre要与时间的函数做乘法，长度不够，因而需要扩展
y01=kron(QAM_Pre1,ones(1,1000));
y02=kron(QAM_Pre2,ones(1,1000));
QAM_Mod=zeros(1,5000);
%modulate by cos
t=0.001:0.001:5;
QAM_Mod=y01.*cos(400*pi*t)+y02.*sin(400*pi*t);
%AWGN channel
QAM_Mod=awgn(QAM_Mod,SNR);
DEC_QAM1=zeros(1,5000);
DEC_QAM2=zeros(1,5000);
%相干解调，乘以同频同相载波
t=0.001:0.001:5;
DEC_QAM1=QAM_Mod.*cos(400*pi*t);
DEC_QAM2=QAM_Mod.*sin(400*pi*t);
%滤掉不需要的高频分量
y1=lowp(DEC_QAM1,20,50,0.1,20,fs);
y2=lowp(DEC_QAM2,20,50,0.1,20,fs);
subplot(2,1,1),plot(t,DEC_QAM2);
ylabel('幅值');xlabel('时间');title('调制信号时域特性');
subplot(2,1,2),draw_fft(DEC_QAM2,fs); %绘出随频率变化的振幅
% subplot(2,2,3);plot(t,2*y2);
% ylabel('幅值');xlabel('时间');title('信号时域特性');
% subplot(2,2,4);draw_fft(2*y2,fs);
%change the altitude into binary bits
De_altitude1=2*y1;
De_altitude2=2*y2;
De_temp01=zeros(1,5);
De_temp02=zeros(1,5);
De_temp1=zeros(1,5);
De_temp2=zeros(1,5);
De_seq1=zeros(1,10);
De_seq2=zeros(1,10);
Result=zeros(1,20);
for i=1:5
De_temp01(1,i)=mean(De_altitude1(1,1000*(i-1)+1:1000*i));
De_temp02(1,i)=mean(De_altitude2(1,1000*(i-1)+1:1000*i));
end
for i=1:5
    if(abs(De_temp01(1,i)-(-3))<1)
        De_temp1(1,i)=0;
    end
    if(abs(De_temp01(1,i)-(-1))<1)
        De_temp1(1,i)=1;
    end
    if(abs(De_temp01(1,i)-1)<1)
        De_temp1(1,i)=2;
    end
    if(abs(De_temp01(1,i)-3)<1)
        De_temp1(1,i)=3;
    end
end
for i=1:5
    if(abs(De_temp02(1,i)-(-3))<1)
        De_temp2(1,i)=0;
    end
    if(abs(De_temp02(1,i)-(-1))<1)
        De_temp2(1,i)=1;
    end
    if(abs(De_temp02(1,i)-1)<1)
        De_temp2(1,i)=2;
    end
    if(abs(De_temp02(1,i)-3)<1)
        De_temp2(1,i)=3;
    end
end
for i=1:5
    De_seq1(1,2*(i-1)+1)=(De_temp1(1,i)-mod(De_temp1(1,i),2))/2;
    De_seq1(1,2*(i-1)+2)=mod(De_temp1(1,i),2);
    De_seq2(1,2*(i-1)+1)=floor(De_temp2(1,i)/2);
    De_seq2(1,2*(i-1)+2)=mod(De_temp2(1,i),2);
end
for i=1:10
    Result(1,2*i-1)=De_seq1(1,i);
    Result(1,2*i)=De_seq2(1,i);
end
Result
