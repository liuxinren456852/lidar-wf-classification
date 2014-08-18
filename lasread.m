function ret = lasread(filename)

%CZYTANIE PLIKU
fid=fopen(filename,'r');%otwarcie pliku do czytania
fseek(fid,24,'bof');%skacze do wersji
major=fread(fid,1,'uint8');minor=fread(fid,1,'uint8');%wersja pliku
if major~=1 || (minor~=0 && minor~=1 && minor~=2 && minor~=3)%wersja rozna od 1.x to koniec programu
    fclose(fid);msgbox('Wybrany plik nie posiada formatu las_v1.x','Koniec programu','warn');%zamkniecie pliku i wyswietlenie wiadomosci
    return
end
lz=[4 1 1 1 1 1 8 1 1 32 32 1 1 1 1 1 1 1 1 5];%liczba zmiennych/znakow
nn={'File Signature (“LASF”):     ','File Source ID:     ','Global Encoding:     ','Project ID - GUID data 1:     ','Project ID - GUID data 2:     ',...
    'Project ID - GUID data 3:     ','Project ID - GUID data 4:     ','Version Major:     ','Version Minor:     ','System Identyfier:     ',...
    'Generating Software:     ','File Creation Day of Year:     ','File Creation Year:     ','Header Size:     ','Offset to Point Data:     ',...
    'Number of Variable Length Records:     ','Point Data Format ID (0-99 for spec):     ','Point Data Record Length:     ',...
    'Number of Point Records:     ','Number of Points by Return:     '};%nazwy pol dla naglowka
fh={'uint8=>char','uint16','uint16','uint32','uint16','uint16','uint8=>char','uint8','uint8','uint8=>char','uint8=>char',...
    'uint16','uint16','uint16','uint32','uint32','uint8','uint16','uint32','uint32'};%format pol dla naglowka
if minor==1 || minor==0;nn(3)={'Reserved:     '};end
if minor==0
    fh(3)={'uint32'};nn([4 5 6 7 12 13 15])={'GUID data 1:     ','GUID data 2:     ','GUID data 3:     ','GUID data 4:     ',...
        'File Date Julian:     ','Year:     ','Offset to Data:     '};%podmiana nazw
end
fseek(fid,0,'bof');%skacze do poczatku
%czytanie i wyswietlenie naglowka
ly=[];
display('HEADER')
for in=1:20;
    if minor==0 && in==2
        ly=0;
    else
        tmp=fread(fid,lz(in),cell2mat(fh(in)));
        if in~=1 && in~=7 && in~=10 && in~=11;
            if in==20;tmp=tmp';end
            ly=[ly,tmp];tmp=num2str(tmp);%#ok<AGROW>
        else
            tmp=tmp';
        end
        display([cell2mat(nn(in)),tmp])
    end
end
wsp=fread(fid,12,'double')';%scale factor: X, Y, Z, offset: X, Y, Z, Max, Min: X, Y, Z
nw={'X scale factor:     ','Y scale factor:     ','Z scale factor:     ','X offset:     ','Y offset:     ','Z offset:     ',...
    'Max X:     ','Min X:     ','Max Y:     ','Min Y:     ','Max Z:     ','Min Z:     '};%nazwy wsp
for in=1:12
    display([cell2mat(nw(in)),num2str(wsp(in))])
end
if minor==3;display(['Start of Waveform Data Packet Record:     ',num2str(fread(fid,1,'uint64'))]);end
display(' ')
%sprawdzenie definicji rekordu POINT DATA
dlrek=[20 28 26 34 57 63];%dlugosci rekordow z definicji formatu 0, 1, 2, 3, 4, 5
if ly(13)~=0 && ly(13)~=1 && ly(13)~=2 && ly(13)~=3 && ly(13)~=4 && ly(13)~=5
    ly(13)=0;msgbox(['Dane czytane bêd¹ na podstawie informacji o d³ugoœci rekordu.',char(10),'Przeczytanych bêdzie maksymalnie 20 bajtów rekordu (jak dla definicji 0).',char(10),'Wartoœci danych mog¹ byæ b³êdne.'],'Nieznana definicja struktury POINT DATA','help')
else
    if dlrek(ly(13)+1)~=ly(14)%rozne dlugosci
        button=questdlg(['D³ugoœæ rekordu z nag³ówka jest niezgodna z definicj¹ rekordu POINT DATA.',char(10),'Ustal d³ugoœæ rekordu na podstawie:'],'Niezgodnoœæ formatu','Nag³ówka','Definicji','Przerwij','Naglowka');
        switch button
            case 'Definicji'
                ly(14)=dlrek(ly(13)+1);
            case 'Przerwij'
                return
            case 'Naglowka'
                ly(13)=0;msgbox(['Dane czytane bêd¹ na podstawie informacji o d³ugoœci rekordu.',char(10),'Przeczytanych bêdzie maksymalnie 20 bajtów rekordu (jak dla definicji 0).',char(10),'Wartoœci danych mog¹ byæ b³êdne.'],'Uwaga','help')
        end
    end
end
%czytanie 'variable length record header'
if ly(11)-ly(10)>=53
    display('VARIABLE LENGTH RECORD HEADER')
    vh1=fread(fid,1,'uint16');display(['Reserved:     ',num2str(vh1)])
    vh2=fread(fid,16,'uint8=>char')';display(['User ID:     ',vh2])
    vh3=fread(fid,1,'uint16');display(['Record ID:     ',num2str(vh3)])
    vh4=fread(fid,1,'uint16');display(['Record Length After Header:     ',num2str(vh4)])
    vh5=fread(fid,32,'uint8=>char')';display(['Description:     ',vh5])
    display(' ')
end

for j = 1 : 10
    
    %reading and displaying data
    display('POINT DATA')
    skok=[0 4 8 12 14 15 16 17 18];%skoki dla wszystkich definicji pliku
    nz={'X (x):     ','Y (y):     ','Z (z):     ','Intensity (I):     ','Return Number (r):     ',...
        'Classification/Classification (c):     ','Scan Angle Rank (-90 to +90) – Left side (a):     ',...
        'User Data (u):     ','Point Source ID (s):     '};%nazwy pol dla danych
    fm={'int32','int32','int32','*uint16','ubit3=>uint8','ubit5=>uint8','*uint8','*uint8','*uint16'};%format pol dla skokow
    lb=[4 4 4 2 3-ly(14)*7 5-ly(14)*7 1 1 2];% the number of bytes / bits of hops
    %the first part of the data, for all definitions DATA POINT same
    for in=1:9
        if skok(in)<ly(14)%can not be exceeded Length Record
            fseek(fid,ly(11)+skok(in),'bof');%skacze do poczatku danych powiekszonych o przeczytane juz dane
            tmp=fread(fid,cell2mat(fm(in)),ly(14)-lb(in));%zmienna tymczasowa
            if in==1 || in==2 || in==3
                tmp=wsp(in)*tmp+wsp(in+3);
            end
            display([cell2mat(nz(in)),num2str(max(tmp)),'     ',num2str(min(tmp))])%wyswietlenie wartosci
            switch in
                case 1
                    x=tmp;
                case 2
                    y=tmp;
                case 3
                    z=tmp;
                case 4
                    I=tmp;
                case 5
                    r=tmp;
                    fseek(fid,ly(11)+skok(in),'bof');
                    tmp1=fread(fid,1,'ubit3'); % jumps to the beginning of the data plus the already read data
                    n=fread(fid,'ubit3=>uint8',ly(14)*8-3);
                    display(['Number of Returns (given pulse) (n):     ',num2str(max(n)),'     ',num2str(min(n))])
                    fseek(fid,ly(11)+skok(in),'bof');
                    tmp2=fread(fid,1,'ubit6'); % jumps to the beginning of the data plus the already read data
                    d=fread(fid,'*ubit1',ly(14)*8-1);
                    display(['Scan Direction Flag (d):     ',num2str(max(d)),'     ',num2str(min(d))])
                    fseek(fid,ly(11)+skok(in),'bof');
                    tmp3=fread(fid,1,'ubit7'); % jumps to the beginning of the data plus the already read data
                    l=fread(fid,'*ubit1',ly(14)*8-1);
                    display(['Edge of Flight Line (l):     ',num2str(max(l)),'     ',num2str(min(l))])
                case 6
                    c=tmp;
                    fseek(fid,ly(11)+skok(in),'bof');tmp4=fread(fid,1,'ubit5');%skacze do poczatku danych powiekszonych o przeczytane juz dane
                    h=fread(fid,'*ubit1',ly(14)*8-1);display(['Classification/Synthetic (h):     ',num2str(max(h)),'     ',num2str(min(h))])
                    fseek(fid,ly(11)+skok(in),'bof');tmp5=fread(fid,1,'ubit6');%skacze do poczatku danych powiekszonych o przeczytane juz dane
                    k=fread(fid,'*ubit1',ly(14)*8-1);display(['Classification/Key-point (k):     ',num2str(max(k)),'     ',num2str(min(k))])
                    fseek(fid,ly(11)+skok(in),'bof');tmp6=fread(fid,1,'ubit7');%skacze do poczatku danych powiekszonych o przeczytane juz dane
                    w=fread(fid,'*ubit1',ly(14)*8-1);display(['Classification/Withheld (w):     ',num2str(max(w)),'     ',num2str(min(w))])
                case 7
                    a=tmp;
                case 8
                    u=tmp;
                case 9
                    s=tmp;
            end
        end
    end

    %czesc druga danych dla definicji czesci POINT DATA innych niz 0
    skokrgb=[20 28 0 28];%skoki dla RGB w zaleznosci od rodzaju plikiu
    skokw=[28 34];%skoki dla waveform w zaleznosci od roddzaju pliku
    nz={'Wave Packet Descriptor Index (D):     ','Byte Offset to Waveform Data (O):     ','Waveform Packet Size in Bytes (W):     ',...
        'Return Point Waveform Location (L):     ','X(t) (X):     ','Y(t) (Y):     ','Z(t) (Z):     '};%nazwy pol dla danych
    fm={'*uint8','*uint64','uint32','*float','*float','*float','*float'};%format pol dla skokow
    lb=[1 8 4 4 4 4 4];%liczba bajtow przeskokow
    if ly(13)~=0
        if ly(13)~=2 % ma GPS
            fseek(fid,ly(11)+20,'bof');%skacze do poczatku danych powiekszonych o przeczytane juz dane
            g=fread(fid,'double',ly(14)-8);display(['GPS Time (g):     ',num2str(max(g)),'     ',num2str(min(g))])
        end
        if ly(13)==2 || ly(13)==3 || ly(13)==5%ma RGB
            fseek(fid,ly(11)+skokrgb(ly(13)-1),'bof');%skacze do poczatku danych powiekszonych o przeczytane juz dane
            R=fread(fid,'*uint16',ly(14)-2);display(['Red (R):     ',num2str(max(R)),'     ',num2str(min(R))])
            fseek(fid,ly(11)+skokrgb(ly(13)-1)+2,'bof');%skacze do poczatku danych powiekszonych o przeczytane juz dane
            G=fread(fid,'*uint16',ly(14)-2);display(['Green (G):     ',num2str(max(G)),'     ',num2str(min(G))])
            fseek(fid,ly(11)+skokrgb(ly(13)-1)+4,'bof');%skacze do poczatku danych powiekszonych o przeczytane juz dane
            B=fread(fid,'*uint16',ly(14)-2);display(['Blue (B):     ',num2str(max(B)),'     ',num2str(min(B))])
        end
        if ly(13)==4 || ly(13)==5%jest waveform
            for in=1:7
                fseek(fid,ly(11)+skokw(ly(13)-3)+sum(lb(1:in))-1,'bof');%skacze do poczatku danych powiekszonych o przeczytane juz dane
                tmp=fread(fid,cell2mat(fm(in)),ly(14)-lb(in));%zmienna tymczasowa
                display([cell2mat(nz(in)),num2str(max(tmp)),'     ',num2str(min(tmp))])%wyswietlenie wartosci
                switch in
                    case 1
                        D=tmp;
                    case 2
                        O=tmp;
                    case 3
                        W=tmp;
                    case 4
                        L=tmp;
                    case 5
                        X=tmp;
                    case 6
                        Y=tmp;
                    case 7
                        Z=tmp;
                end
            end
        end
    end
    display(' ')
end;

fclose(fid);

ret = [];