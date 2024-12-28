unit idf_enreg;
{
Auteur: Premartin Patrick
Date: 13/09/1991.
      17/09/1991.
      19/09/1991.
      23/09/1991.
      26/03/1992.
Langage: Turbo Pascal 6.0

But: D‚clarations et utilisation des enregistrements de INDEX.
}
interface
type
    p_enreg = ^o_enreg;
    o_enreg = object
                    adr : pointer;
                    next,
                    previous : p_enreg;
                    constructor init (avant, apres : p_enreg);
                    procedure set_champ (n : byte; ch : string);
                    function get_champ (n : byte) : string;
                    destructor done;
    end;

var
   titre,
   first,
   last : p_enreg;

implementation
uses
    idf_var,
    u_idf;

constructor o_enreg.init (avant, apres : p_enreg);
begin
     next := apres;
     previous := avant;
     adr := init_idf_enreg (nb_champs, champs);
end; { O_Enreg.Init }

procedure o_enreg.set_champ (n : byte; ch : string);
begin
     set_idf_champ (n, nb_champs, champs, adr, ch);
end; { O_Enreg.Set_Idf_Champ }

function o_enreg.get_champ (n : byte) : string;
begin
     get_champ := get_idf_champ (n, nb_champs, champs, adr);
end; { O_Enreg.Get_Champ }

destructor o_enreg.done;
begin
     if (previous <> nil)
     then
         previous^.next := next;
     {endif}
     if (next <> nil)
     then
         next^.previous := previous;
     {endif}
     del_idf_enreg (nb_champs, champs, adr);
end; { O_Enreg.Done }

begin
     titre := nil;
     first := nil;
     last := nil;
end. { Fin de l'unite 'Idf_Enreg'. }
