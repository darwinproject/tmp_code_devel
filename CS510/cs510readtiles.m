function [fld]=cs510readtiles(dirIn,filIn,iStep,iFld);
%[fld]=cs510readtiles(dirIn,filIn,iStep,iFld);
%e.g. [fld]=cs510readtiles('ptr/','_',72,21);
%e.g. [fld]=cs510readtiles('ptr/','_',72,'TRAC21')

if isa(iFld,'char')
    [dims,prec,tiles,fldList]=cs510readmeta(dirIn);
    fldname = iFld;
    fmtstr = ['%-' num2str(length(fldList{1})) 's'];
    iFld = find(strcmp(fldList,sprintf(fmtstr,fldname)));
    if isempty(iFld)
        error(['Field ' fldname ' is not listed in the metadata file.'])
    end
else
    [dims,prec,tiles]=cs510readmeta(dirIn);
end
n1=tiles(1,2);
n2=tiles(1,4);
if length(dims) == 3
    n3=dims(3);
    recl3D=n1*n2*n3*4;
    shape = [n1 n2 n3];
    numels = n1*n2*n3;
else
    recl3D=n1*n2*4;
    shape = [n1 n2];
    numels = n1*n2;
end

if strcmp(prec,'float64'); recl3D=2*recl3D; end;

fld=zeros(dims);
for iTile=1:size(tiles,1);
  fil=sprintf('res_%04d/%s.%010d',iTile-1,filIn,iStep);
  fil=dir([dirIn filesep fil '*']);
  %
  fid=fopen([fil.folder filesep fil.name],'r','b');
  status=fseek(fid,(iFld-1)*recl3D,'bof');
  tmp=reshape(fread(fid,numels,prec),shape);
  tmp(tmp==0)=NaN;
  fclose(fid);
  %
  ii=[tiles(iTile,1):tiles(iTile,2)];
  jj=[tiles(iTile,3):tiles(iTile,4)];
  fld(ii,jj,:)=tmp;
end;
fld=convert2gcmfaces(fld);

