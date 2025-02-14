clear; close all; clc;
%% ������ ������� �������������� ������������� ��������

% ���� ����� ������� ����������:
f = 4*1.023; % ���, �������� ������� ���� �������������� ������� �������
N = [-1 1 -1 -1 -1 -1 1 1 -1 -1 1 1 -1 1 1 1 1 1 1 -1 1 -1 -1 -1 -1 1 1 -1 1 1 1 -1 1]; % ��� ������������������
d = 10e2/f; % ������������ ���� � �� (��� �������������� ������� � �������� 4*1.023���
ds = d/20; % ������������ ������,�� (������������ "�������" �����)
k = 4*d/ds; % ����������� ���������� ��� ������������������ (���-�� ��������� �� ���� ��� ���)
m = 4; % ������� ���������� ����� ��� (����������� ��������� ���������� ������������������)

b = length(N)*k; % ����������� ����� ������� �������������� ������� res
res = zeros(1,2*b);% ������� �������� ��������� ������ ��������������
%% ���������� ������� ���
for qind=1:2
    Q=pi*(qind-1); %���� ���������� �������
    a=0.1*2*(1.5-qind);%����������� ��������� ���������� �������
for i = 0 : length(N) - 1 
    for j = 0 : k - 1
         X(i * k + j + 1) = N(i + 1);%��������� ��� � k ��� 
    end
end

%% ������������ ����������� ������������������ ��� ���
 for i = 0 : length(N) - 1
    for j = 0 : k - 1
      G(i * k + j + 1) = 1 - mod(floor(j * m / k), 2) * 2;
    end
 end

%% ������������ ��� ��� ��������� ��.������������������ � �����������
for i=1:length(X)
    Xmod(i)=G(i)*X(i);%������, ������� ��������� �� ���� ���������
end

%% ������������ �������
y = ones(1,length(Xmod)-1);
 for i=1:(length(Xmod)-1)
     if sign(Xmod(i))> sign(Xmod(i+1))
        y(i)=-1;
        y(i-1)=-1;
        y(i+1)=-1;
        y(i+2)=-1;
     end
     if sign(Xmod(i))< sign(Xmod(i+1))
         y(i)=1;
         y(i-1)=1;
         y(i+1)=1;
         y(i+2)=1;
     end
 end
%% ���������� �������� ������� res ��������� ������ ��������������
Ro=xcorr(Xmod);%��� �������� ������� � �������, ���������� ��� �������� (��� ������)
deltaR=xcorr(Xmod,y);% ��� �������� ������� � ��������� ������������������ 
 for sigma=0:k    %�������� ������������ �������
 for i=1:(length(Xmod))
     if sigma>=i 
         X2(i)=Xmod(i);
     else
         X2(i)=Xmod(i)+a*Xmod(i-sigma);
         % ������,��� ����� "�������" � "�����������" �������
     end
 end

     Ro2=xcorr(Xmod,X2);% ��� "�������" ������� � "�����������"
     deltaR2=xcorr(y,X2);%��� ��������� ������������������ � "�����������" �������
     
   %%���������� ����������������� ��������������
     Z1=1/(1+((a*sin(Q)*Ro2)/(Ro+a*cos(Q)*Ro2)).^2);%������������ ��
     Z2=deltaR+a*cos(Q)*deltaR2+(a*sin(Q))^2*(deltaR2.*Ro2)/(Ro+Ro2*a*cos(Q));
     Z3=Ro+a*cos(Q)*Ro2+(a*sin(Q))^2*Ro2.^2/(Ro+Ro2*a*cos(Q));
     Zdc=Z1.*Z2.*Z3;%�������� �������� ������������ �������������� (��)
     
     %%����� ������ �������������� ��� ������ ��������� Zdc=0 (������������
     %%������������� �����)
     zmax1 = -1000000000;
     c1=0;c2=0;c3=0;
for i=1:length(Zdc)-1 %������� �������� ��
    if Zdc(i)> zmax1 
      c1 = i; %�������� ����� ���������
      zmax1 = Zdc(i);% �������� ����� ���������
    end
end   

 for j=c1:-1:2%������� ������� ��� ����������� �� � �����
    if sign(Zdc(j)) > sign(Zdc(j-1))
      c2=j-1;%������� ����� ������ ����
      c3=j;%������� ����� ������ ����
      zmax2=Zdc(j-1);%�������� ����� ������ ����
      zmax3=Zdc(j);%�������� ����� ������ ����
      res(qind,sigma+1)=-zmax2*(c3-c2)/(zmax3-zmax2)+c2;
      %����������� ��������� ������ �� ����� �2,�3,zmax2,zmax3 � ����� �� ����������� � �����
          if sigma > 0 
             res(qind,sigma+1) = res(qind,sigma+1) - res(qind,1);
             %����������� �������������� ������� �������� ��������� ������ ��������������
          end
          break
    end
 end
 end
 res(qind,1)=0;
 
 for i=1:length(res)
  result_x(qind,i)=((10^-5)*res(qind,i)*3*(10e8)/k);%��������������� ��� �������
  result_y(qind,i)= (d*i)/k;%��������������� ��� �������, ��
 end
 
end

%% ����������� ����������� ��������� ������ ��������������

multipath_delay_zero_phase_y=(result_x(1,1:length(result_x)));
% �������� ������ �������������� ��� ������� ���������� � ����� ����
multipath_delay_zero_phase_x=result_y(1,1:length(result_y));
multipath_delay_pi_phase_y=(result_x(2,1:length(result_x)));
% �������� ������ �������������� ��� ������� ���������� � ����� "��"
multipath_delay_pi_phase_x=result_y(2,1:length(result_y));

figure(1);plot(multipath_delay_zero_phase_x,multipath_delay_zero_phase_y);
set(findobj(gca,'Type','line','Color',[0 0 1]),'Color','black','LineWidth',2);hold on;
plot(multipath_delay_pi_phase_x,multipath_delay_pi_phase_y);
legend('Q=0','Q=pi');
title('��������� ������ �������������� �������');
xlabel('�������� �������,��');
ylabel('�������� ������, �');
xlim([0 500]);