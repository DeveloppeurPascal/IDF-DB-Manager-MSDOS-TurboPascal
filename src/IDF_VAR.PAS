unit idf_var;
{
Auteur: Pr‚martin Patrick
Date: 13/09/1991. 17/09/1991. 18/09/1991. 19/09/1991. 26/03/1992. 11/09/1992.
      12/09/1992.
Langage: Turbo Pascal 6.0

But: D‚claration des variables de INDEX.
}
interface
uses
    u_idf;

const
     num_vers = '4.0';
     dat_vers = '12 Sept 1992';

var
   nb_champs : byte;
   champs : t_tab_champ;
   debug,
   activ,
   modif : boolean;
   num_enreg,
   nb_enreg : word;

implementation
uses
    u_parametre;

procedure idf_var_init;
var
   i : integer;
begin
     for i := 1 to nb_max_champs do
         begin
              champs [i].taille := 0;
              champs [i].typ := 1;
              champs [i].offset := 0;
         end;
     {endfor}
     nb_champs := 0;
     modif := false;
     activ := false;
     num_enreg := 0;
     nb_enreg := 0;
end; { Idf_Var_Init }

begin
     debug := param_del ('DEBUG');
     idf_var_init;
end. { Fin de l'unit‚ 'Idf_Var'. }
