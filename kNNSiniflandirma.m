% Muhammet Kurt
% 130207043

%%
function saySonuc=kNNSiniflandirma(kNN)


%Veriler yukleniyor kodun sizin pc nizde calismasi icin dosya yolunu
%degistirmeniz gerekmektedir.
load 'C:\Users\Muhammet\Documents\MATLAB\uzaktan_algilama-proje\Indian_pines_gt'
load 'C:\Users\Muhammet\Documents\MATLAB\uzaktan_algilama-proje\Indian_pines'
load 'C:\Users\Muhammet\Documents\MATLAB\uzaktan_algilama-proje\Indian_pines_corrected'

%kullanici girdi vermeyi unutursa default olarak kNN degerimiz 5 olsun
%dedim ki arttikca kod performansi artar islem suresi azalir
if nargin <1
    kNN=5;
end


% ground truth matrisinin boyutlarini kullanmak uzere aldim
[w,h]=size(indian_pines_gt); 
%ground truth desisken adi cok uzun oldugu icin kisaca gt dedim
gt=indian_pines_gt;
%kullanilabilir diye bunlari da aldim
hip=indian_pines_corrected;
hip2=indian_pines;

%% Etiket sayisi bulunuyor
% etiketlerin yuzde onunu almak icin etiketlerin sayilarini bulalim
numLabel=zeros(1,16); %onalti etiket var


% burada tum ground truth taranak icerdigi etiketlerin sayisi bulunuyor
for i=1:w
    for j=1:h        
        switch indian_pines_gt(i,j)
            case 1
                numLabel(1)=numLabel(1)+1;
            case 2
                numLabel(2)=numLabel(2)+1;        
            case 3
                numLabel(3)=numLabel(3)+1;        
            case 4
                numLabel(4)=numLabel(4)+1;        
            case 5
                numLabel(5)=numLabel(5)+1;        
            case 6
                numLabel(6)=numLabel(6)+1;        
            case 7
                numLabel(7)=numLabel(7)+1;        
            case 8
                numLabel(8)=numLabel(8)+1;        
            case 9
                numLabel(9)=numLabel(9)+1;        
            case 10
                numLabel(10)=numLabel(10)+1;        
            case 11
                numLabel(11)=numLabel(11)+1;        
            case 12
                numLabel(12)=numLabel(12)+1;        
            case 13
                numLabel(13)=numLabel(13)+1;        
            case 14
                numLabel(14)=numLabel(14)+1;        
            case 15
                numLabel(15)=numLabel(15)+1;        
            case 16
                numLabel(16)=numLabel(16)+1;
            otherwise
                continue; % sifir etiketi icin burasi calisacak
        end     
    end
end
toplamEtiketSayisi=sum(numLabel);
% etiketi tek sutun haline donusturdum gerek yok ama boyle kullanmak
% benim kod yazmami kolaylastiriyor
numLabel=numLabel';

% etiket sayilarina etiket adlarini ve yuzdelik karsiliklarini da eklemek
% icin matrisime ayni boyutta iki adet sutun daha ekliyorum
rowForAdd=zeros(16,1);

numLabel=[rowForAdd,rowForAdd,numLabel]; % sutunlar eklendi
toplam=0; %kac tane etiket oldugunu bulmak icin toplam degiskeni olusturdum
for  i=1:16 % sifir etiketi olmadigi icin 1den 16ya kadar
    numLabel(i,1)=i; % ilk sutuna etiket adi
    numLabel(i,2)=round(0.1*numLabel(i,3)); % ikinci sutuna yuzde onu
    toplam=numLabel(i,2)+toplam; % toplam etiket yuzde onluklarin adedi
    
end


%% Egitim matrisi olusturma

% tum etiketlerin konumlarini tutar
etiketKonumlari=zeros(w*h,3);
maxX=max(max(gt)); % en buyuk etiketi tutar yani 16

% yuzde onluk etiket sayilarini rastgele tutan bir degisken
egitimMatrisi=zeros(toplam,3); 


% kaldigimiz yerden devam etmek için koydugumuz bir satir sayisini tutmaya yarayan degisken
kalinanSatir=1; 

% buda yuzde onluk adedince etiteki rastgele aldgimiz degiskenin satir
% sayisini tutan bir degiskenimiz
kalinanSatir2=1;

for i=1:maxX %tum etiketler taraniyor
    
    % gr?und truth icerisinde istenilen etiket find komutu ile hem
    % koordinatlari bulunuyor -in1 x, in2 y koordinati- hemde kac adet
    % oldugunu buluyor cunku in3 aslinda her koordinat icin logic 1 ureten
    % bir degisken onunda boyut olarak satiri bize adedi verir bu nedenle
    % sz1 degiskenini kullaniyoruz.
    [xKoor,yKoor,LogicBilgi]=find(gt==i); 
%     [sz1,sz2]=size(in3); bu sekilde de olabilirdi
    adet=size(LogicBilgi,1);
    
    % tum etiketlerin koordinatsal bilgilerini tutuyor ilk satir x ekseni
    % ikinci satir y ekseni ucuncu satir etiket adi
    etiketKonumlari(kalinanSatir:kalinanSatir-1+adet,1)=xKoor;
    etiketKonumlari(kalinanSatir:kalinanSatir-1+adet,2)=yKoor;
    etiketKonumlari(kalinanSatir:kalinanSatir-1+adet,3)=i;
    
    % yuzde onluk adetde veri aliniyor.
    for k=1:numLabel(i,2)
        % etiketKonumlari degiskenine eklenen sayi araliginda yani yeni eklenen
        % etiketin adedi araliginda rastgele bir sayi seciliyor ki bu bizim
        % egitim kumemizi olusturmamiza yardim ediyor
        x=round((rand(1)*adet)+kalinanSatir);
        % x degiskeni belirlenen siniri asarsa sinira cekiliyor
        if x>kalinanSatir+adet
            x=kalinanSatir;
        end
        % elde edilen x degiskeni satirindaki tum veriler aliniyor
        egitimMatrisi(kalinanSatir2,:)=etiketKonumlari(x,:);
        % konum degiskeni icin olusuturulan satir bilgisi guncelleniyor
        kalinanSatir2=kalinanSatir2+1;
        
    end
end

%% kNN yontemi uygulaniyor


% Cell Array matrisi olusturuluyor ki tum koordinatlarin uzaklik bilgisinin
% yaninda etiket bilgisini de tutabilsin
pikselDim={};

% satir sutun taranarak etiketlerin koordinatsal uzakliklari bulunuyor
for i=1:w
    for j=1:h
        if gt(i,j)~=0 % 0 etiketli koordinatlar dikkate alinmiyor
            for k=1:toplam % tum yuzde onluk etiketlere olan uzakligi isleniyor

                % koordinatlarin etiketlere olan uzakligi onceden
                % olusturulan egitimMatrisi matrisindeki koordinatlar
                % kullanilarak bulunuyor 
                dim=sqrt((i-egitimMatrisi(k,1))^2+(j-egitimMatrisi(k,2))^2);
                % Cell Array matrise atama islemi gerceklestiriliyor
                pikselDim{i,j}(k,1)=dim;
                % Etiket adi aktariliyor
                pikselDim{i,j}(k,2)=egitimMatrisi(k,3);

            end
        else
            % Etiketi 0 olan koordinatlara sonsuz degeri verilerek isleme
            % daha sonra tabi tutulmasi engelleniyor
            pikselDim{i,j}=Inf; %islenmeyecek
            
        end
    end
end


% Girilen kNN'e gore en kucuk degerler alinir
for i=1:w % tum satirlar taraniyor
    for j=1:h % tum sutunlar taraniyor
        if gt(i,j)~=0 % sifir etiketli olanlar islenmiyor
            for test=1:kNN % kNN kadar min degeri aliniyor
                
                % min fonksiyonu ile minimum degeri ver indeksi aliniyor
                % zaten vektor olarak min'i kullandigimiz icin indeks satir
                % sayisini veriyor
                [minValue,indeks]=min(pikselDim{i,j}(:,1)); 
                pikselDim{i,j}(test,3)=minValue; % atamalar yapiliyor
                pikselDim{i,j}(test,4)=pikselDim{i,j}(indeks,2); %etiketi atiyoruz
                % Bulunan min degeri sifirlaniyor ki bir daha oraya gelmesin
                % bu sifirlama islemi min degerini aradigimiz icin Inf yani
                % sonsuz degerini vererek oluyor
                pikselDim{i,j}(indeks,1)=Inf;
            end
        else
            continue; % etiket sifirsa islem yapmadan devam et
        end
    end
end




% Yukarida en kucuk kNN tane etiket bulundu simdi ise bulunanlar arasindan
% kendini en cok hangisi tekrar ediyor bunu buluyoruz.
% Kendini en cok tekrar eden etiketi bulmak icin etiket tutucu bir 
% degisken olusturuyoruz
etiketBul=zeros(1,16); 
for i=1:w % satirlar okunuyor
    for j=1:h % sutunlar okunuyor
        % Sifir etiketli koordinatlar icin pikselDim cell array matrisine
        % Inf yani sonsuz yazilmisti ve bu cell lerin boyutu diger
        % koordinatlarin aksine 1'dir bu nedenle sifir etiketine sahip 
        % koordinatlar? isleme tabi tutmuyoruz.
        if size(pikselDim{i,j},1) > 1 
            for k=1:kNN % en kucuk kNN adet etiket secmistik bu yuzden bunlar uzerinden taram yapiyoruz
                % kendini tekrar eden etiketi buluyoruz.
                switch pikselDim{i,j}(k,4)
                    case 1
                        etiketBul(1)=etiketBul(1)+1;
                    case 2
                        etiketBul(2)=etiketBul(2)+1;        
                    case 3
                        etiketBul(3)=etiketBul(3)+1;        
                    case 4
                        etiketBul(4)=etiketBul(4)+1;        
                    case 5
                        etiketBul(5)=etiketBul(5)+1;        
                    case 6
                        etiketBul(6)=etiketBul(6)+1;        
                    case 7
                        etiketBul(7)=etiketBul(7)+1;        
                    case 8
                        etiketBul(8)=etiketBul(8)+1;        
                    case 9
                        etiketBul(9)=etiketBul(9)+1;        
                    case 10
                        etiketBul(10)=etiketBul(10)+1;        
                    case 11
                        etiketBul(11)=etiketBul(11)+1;        
                    case 12
                        etiketBul(12)=etiketBul(12)+1;        
                    case 13
                        etiketBul(13)=etiketBul(13)+1;        
                    case 14
                        etiketBul(14)=etiketBul(14)+1;        
                    case 15
                        etiketBul(15)=etiketBul(15)+1;        
                    case 16
                        etiketBul(16)=etiketBul(16)+1;
                    otherwise
                        continue; % Sifir buraya gelip islenmiyor
                end
            end
        
        % Kendini en cok tekrar eden degeri max fonk. ile buluyoruz
        [maxValue,maxIndex]=max(etiketBul);

        % Burada kendini en cok tekrar eden etiket indeks degerine esit
        % olacagi icin indeks degerini sonuc olarak kabul edip her hucrenin
        % icerisinde bildigimiz bir noktaya yerlestiriyoruz ki bir dahakine
        % oradan cekip kullanabilelim
        pikselDim{i,j}(1,6)=maxIndex; %sonuc bulundu
        etiketBul(:,:)=0; % sayac bosaltildi
        
        end
    
    end
end

%% Sayisal Sonuc bulunuyor
% Bulunan sonuclar orjinal degeri ile karsilastiriliyor.

% Sayisal sonuclari tutacak bir matris tanimlandi
saySonuc=zeros(w,h);

hata=0;
dogru=0;
for i=1:w
    for j=1:h
        if size(pikselDim{i,j},1)>1 % sifir etiketli koordinatlar islenmedi
            % Orjinalden sonuc cikariliyor ve sonuc matrisine ataniyor
            % sonuc matrisinin icerisine girip hangi koordinatlar dogru
            % bulunmus hangileri yanlis bulunmus gorulebilir, dogru sonuc
            % icin sonuc matrisinde sifir degeri gorulmeli
            saySonuc(i,j)=gt(i,j)-pikselDim{i,j}(1,6);
            % Sonuclar anlik olarak ekranda gostermek icin alltaki yorum
            % satirlari acilmalidir
            if saySonuc(i,j)==0
%                 fprintf('%dx%d koordinati icin sonuc: DOGRU\n',i,j);
                dogru=dogru+1;
            else
%                 fprintf('%dx%d koordinati icin sonuc: YANLIS\n',i,j);
                hata=hata+1;
            end

        end
    end
%     fprintf('-------------------%d satir bitti---------------------\n',i);
end

%% Renklendirme yapiliyor

fprintf('\n------------------Sonuclar--------------------\nPiksel Sayilari\n\n');

str1=strcat(num2str((100*(dogru/toplamEtiketSayisi))),'%');
str2=strcat(num2str((100*(hata/toplamEtiketSayisi))),'%');
str3=strcat(num2str(100),'%');

fprintf('DOGRU: %d (%s)\n',dogru,str1);

fprintf('YANLIS: %d (%s) \n',hata,str2);
fprintf('+__________\n');
fprintf('TOPLAM: %d(%s)\n',toplamEtiketSayisi,str3);



% imge olusturmak icin degisken tanimlaniyor
son=uint8(zeros(w,h,3));

for i=1:w % satirlar taraniyor
    for j=1:h % sutunlar taraniyor
        if size(pikselDim{i,j},1) >1 % sifir etiketli koordinatlar islenmiyor
            % renklendirme icin her etikete ayri bir renk kodu ataniyor
            switch pikselDim{i,j}(1,6)
                case 1
                    son(i,j,1)=255;
                    son(i,j,2)=0;
                    son(i,j,3)=0;
                case 2

                    son(i,j,1)=0;
                    son(i,j,2)=255;
                    son(i,j,3)=0;
                case 3

                    son(i,j,1)=0;
                    son(i,j,2)=0;
                    son(i,j,3)=255;
                case 4

                    son(i,j,1)=255;
                    son(i,j,2)=255;
                    son(i,j,3)=125;
                case 5

                    son(i,j,1)=0;
                    son(i,j,2)=255;
                    son(i,j,3)=255;
                case 6

                    son(i,j,1)=255;
                    son(i,j,2)=0;
                    son(i,j,3)=255;
                case 7

                    son(i,j,1)=255;
                    son(i,j,2)=255;
                    son(i,j,3)=255;
                case 8

                    son(i,j,1)=125;
                    son(i,j,2)=0;
                    son(i,j,3)=0;
                case 9

                    son(i,j,1)=0;
                    son(i,j,2)=125;
                    son(i,j,3)=0;
                case 10

                    son(i,j,1)=70;
                    son(i,j,2)=70;
                    son(i,j,3)=125;
                case 11

                    son(i,j,1)=255;
                    son(i,j,2)=255;
                    son(i,j,3)=0;
                case 12

                    son(i,j,1)=70;
                    son(i,j,2)=125;
                    son(i,j,3)=70;
                case 13

                    son(i,j,1)=125;
                    son(i,j,2)=70;
                    son(i,j,3)=125;
                case 14

                    son(i,j,1)=70;
                    son(i,j,2)=125;
                    son(i,j,3)=125;
                case 15

                    son(i,j,1)=125;
                    son(i,j,2)=125;
                    son(i,j,3)=70;
                case 16

                    son(i,j,1)=125;
                    son(i,j,2)=125;
                    son(i,j,3)=125;
                otherwise
                    son(i,j,1)=0;
                    son(i,j,2)=0;
                    son(i,j,3)=0;
            end
        end
    end
end

% Sonuc ekranda gosteriliyor.
figure,imshow(son);


end