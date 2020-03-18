% Zespo³: Katarzyna Muter, Katarzyna Rzeczyca
% Temat: 31. Diagnostyka schorzen serca za pomoca sieci SOM
% Dane: spectf_heart_MLR
% Prowadzacy: dr inz. Bogumil Konarzewski
clear all;
close all; 

%% Nauka sieci

% Wczytanie danych
train_data = importdata('SPECTF.train');
a=[80,90,100,110,120,130,140,150,160,170,180,190,200];
s=1;
wektorwynikow=zeros(130,3);
for r=1:13
    tn=a(r);
for v=1:10
% Zmienne i funkcje
n=5;  %liczba neuronow w sieci
alfa0=0.5;   %wspolczynnik szybkosci uczenia- duzy ze wzgledu na hiperboliczna funkcje zmieny alfa w czasie
C=2; %C>1; C const.; czas uczenia (wg.Kohonena) ok.100*C
% tn=200; %iloœæ iteracji
[w,k]=size(train_data); %w-wiersze; k-kolumny
W=zeros(n,n,k-1); % inicjalizacja macierzy wag
for i=1:n
    for j=1:n
        W(i,j,:)=train_data(randi(80),2:end); % wybór losowych wag neuronów 
    end
end
alfaFun= @(t) (alfa0*C)/(C+t);  %hiperboliczna zmiana alfa
% h= @(w,wc,t) exp((-norm(w-wc)^2)/(sqrt(tn)+5-sqrt(t))); %funkcja sasiedztwa (gaussowska)

for t=1:tn    %liczba iteracji
    losowe_dane = train_data(randi(80),2:end); % wybór losowego wektora danych ternuj¹cych
        % % %
        d=zeros(n,n);   %macierz wartoœci roznicy miedzy kazdym neuronem i wektorem wejsciowym
        for j=1:n    %iteracja po neuronach-wiersze sieci
            for l=1:n    %iteracja po neuronach-kolumny sieci
                d(j,l)=norm(losowe_dane-pobierz_wektor(W,j,l));
            end
        end
        [wcx, wcy] = xyminimalne(d); % wcx - numer wiersza, wcy - numer kolumny neuronu zwyciezkiego
        for j=1:n
            for l=1:n
                if (j == wcx && l == wcy)
                    h = 1;
                elseif (j == wcx-1 && l == wcy-1 || j == wcx && l == wcy-1 || j == wcx-1 && l == wcy  || j == wcx+1 && l == wcy || j == wcx-1 && l == wcy+1 || j == wcx && l == wcy+1 || j == wcx+1 && l == wcy+1 || j == wcx+1 && l == wcy-1)
                    h = 0.3;
                else
                    h = 0;
                end
            end
        end
        for j=1:n    %iteracja po neuronach-wiersze sieci
            for l=1:n    %iteracja po neuronach-kolumny sieci
                %W(j,l,:)=pobierz_wektor(W,j,l)+alfaFun(t)*h(pobierz_wektor(W,j,l),pobierz_wektor(W,wcx,wcy),t)*(losowe_dane-pobierz_wektor(W,j,l));   %zmiana wag neuronów zgodnie z funkcja sasiedztwa
                W(j,l,:)=pobierz_wektor(W,j,l)+alfaFun(t)*h*(losowe_dane-pobierz_wektor(W,j,l));
            end
        end
        % % %
end

%% Kalibracja

% Wczytanie danych
sr_pato = sum(train_data(1:40,2:end))/40; %œredni wektor danych patologicznych
sr_fizjo = sum(train_data(41:80,2:end))/40; %œredni wektor danych fizjologicznych
f=1;
p=1;
for j=1:n    %iteracja po neuronach-wiersze sieci
    for l=1:n    %iteracja po neuronach-kolumny sieci
        d_pato = norm(sr_pato-pobierz_wektor(W,j,l));
        d_fizjo = norm(sr_fizjo-pobierz_wektor(W,j,l));
        if d_pato >= d_fizjo
            wsp_fizjo(f,:) = [j,l];
            f = f+1;
        elseif d_pato < d_fizjo
            wsp_pato(p,:) = [j,l];
            p = p+1;
        end
    end
end
        
%% Test

% Wczytanie danych
test_data = importdata('SPECTF.test');

% Zmienne i funkcje
[wt,kt]=size(test_data);  %w-wiersze; k-kolumny
lp=0;   %liczba zdiagnozowanych patologii
lf=0;   %liczba zdiagnozowanych fizjologii

for w=1:wt
    d_test = zeros(n,n);
    for j = 1:n
        for l = 1:n
            d_test(j,l)=norm(test_data(w,2:end)-pobierz_wektor(W,j,l));
        end
    end
    [x_test,y_test] = xyminimalne(d_test);
    wynik = sprawdzFczyP(x_test, y_test, wsp_fizjo, wsp_pato);
    if wynik == 0
        lf = lf+1;
    elseif wynik == 1
        lp = lp+1;
    end
end
wektorwynikow(s,:)=[tn,lp,lf];
s=s+1;
end
end
sredniwynik=zeros(13,3);
for i=1:13
sredniwynik(i,:)=[a(i),mean(wektorwynikow((i-1)*10+1:i*10,2)),mean(wektorwynikow((i-1)*10+1:i*10,3))];
end
