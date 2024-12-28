unit idf_commande;
{
Auteur: Premartin Patrick
Date: 18/09/1991.
      19/09/1991.
      26/03/1992.
Langage: Turbo Pascal 6.0

But: D‚claration des commandes utilis‚es par le logiciel (Turbo Vision)
     Index 4.x
}
interface
const
  { Menu: ð }
     cm_about = 1000; { Boite d'infos sur le programme. }
  { Menu: System }
     cm_save = 1100; { Sauvegarde de la base actuelle. }
     cm_load = 1101; { Chargement d'une nouvelle base. }
     cm_create = 1102; { Creation d'une nouvelle base. }
     cm_directory = 1103; { Changer le r‚pertoire courant. }
     cm_date = 1104; { Changer la date courante. }
     cm_time = 1105; { Changer l'heure courante. }
     cm_couleur = 1008; { Changement de la palette de couleur de
                        l'environnement. }
     cm_dos = 1106; { Acces au Dos Shell. }
     cm_quit = 1107; { Arret du programme apres sauvegarde ‚ventuelle. }
  { Menu: Options }
     cm_edit_modify = 1200; { Edition ou modification. }
     cm_sort = 1201; { Tri de la base actuelle. }
     cm_search = 1202; { Recherche d'un element. }
     cm_insert = 1203; { Insertion d'un ‚l‚ment. }

implementation
end. { Fin de l'unite 'Idf_Commande'. }
 