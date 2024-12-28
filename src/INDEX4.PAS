program index;
{
Auteur: Patrick Premartin
Date: 17/09/1991. 18/09/1991. 19/09/1991. 23/09/1991. 26/03/1992. 31/03/1992.
      11/09/1992. 12/09/1992.
Langage: Turbo Pascal 6.0

But: Gestion de base de donn‚e (champs variables de chaines et d'entiers...)
}

{$m 32768, 0, 655350}
{ $define demo_vers}

uses
    app,
    dos,
    colorpal,
    dialogs,
    drivers,
    gadgets,
    helpfile,
    memory,
    menus,
    msgbox,
    objects,
    stddlg,
    mouse,
    views,
    xdialog,
    olf_software,
    u_msg,
    u_sgf,
    idf_commande,
    idf_base,
    idf_options,
    idf_time_date,
    idf_var;

type
    p_prg = ^o_prg;
    o_prg = object (tapplication)
                   file_name : string;
                   heure : PClockView;
                   heap : PHeapView;

                   constructor init;
                   procedure idle; virtual;
                   procedure initmenubar; virtual;
                   procedure initstatusline; virtual;
                   function getpalette : ppalette; virtual;
                   procedure handleevent (var event : tevent); virtual;
                   procedure GetEvent (var Event : TEvent); virtual;
            end;

var
   res : word;
{
**************************************************************************
}
constructor o_prg.init;
var r : trect;
begin
     registerobjects;
     registerviews;
     registermenus;
     registerdialogs;
     registerapp;
     registerhelpfile;
     tapplication.init;
     desktop^.helpctx := hcnocontext;
     getextent (r);
     r.a.x := r.b.x-9;
     r.b.y := r.a.y+1;
     heure := new (pclockview, init (r));
     insert (heure);
     getextent (r);
     dec (r.b.x);
     r.a.x := r.b.x-9;
     r.a.y := r.b.y-1;
     if (debug)
     then
       begin
         heap := new (pheapview, init (r));
         insert (heap);
       end
     else
       heap := nil;
     {endif}
end; { O_Prg.Init }
{
**************************************************************************
}
procedure o_prg.idle;
begin
  tapplication.idle;
  if (heure <> nil)
  then
    heure^.update;
  {endif}
  if ((heap <> nil) and debug)
  then
    heap^.update;
  {endif}
end; { O_Prg.Idle }
{
**************************************************************************
}
procedure o_prg.initmenubar;
var
   r : trect;
begin
     getextent (r);
     r.b.y := succ (r.a.y);
     menubar := new (pmenubar, init (r,
       newmenu (
         newsubmenu ('~'#240'~', hcnocontext,
           newmenu (
             newitem (get_msg (1)+' '+num_vers+'...', '', kbnokey, cm_about, hcnocontext,
             nil)
           ),
         newsubmenu (get_msg (2), hcnocontext,
           newmenu (
             newitem (get_msg (3), 'F2', kbf2, cm_save, hcnocontext,
             newitem (get_msg (4), 'F3', kbf3, cm_load, hcnocontext,
             newitem (get_msg (5), 'F4', kbf4, cm_create, hcnocontext,
             newline (
             newitem (get_msg (6), '', kbnokey, cm_directory, hcnocontext,
             newitem (get_msg (7), '', kbnokey, cm_date, hcnocontext,
             newitem (get_msg (8), '', kbnokey, cm_time, hcnocontext,
             newitem (get_msg (9), '', kbnokey, cm_couleur, hcnocontext,
             newline (
             newitem (get_msg (10), '', kbnokey, cm_dos, hcnocontext,
             newitem (get_msg (11)+' '+num_vers, '', kbnokey, cm_quit, hcnocontext,
             nil)))))))))))
           ),
         newsubmenu (get_msg (12), hcnocontext,
           newmenu (
             newitem (get_msg (13), 'F5', kbf5, cm_edit_modify, hcnocontext,
             newitem (get_msg (14), 'F6', kbf6, cm_sort, hcnocontext,
             newitem (get_msg (15), 'F7', kbf7, cm_search, hcnocontext,
             newitem (get_msg (16), 'F8', kbf8, cm_insert, hcnocontext,
             nil))))
           ),
         nil)))
       )));
end; { O_Prg.InitMenuBar }
{
**************************************************************************
}
procedure o_prg.initstatusline;
var
   r : trect;
begin
     getextent (r);
     r.a.y := pred (r.b.y);
     statusline := new (pstatusline, init (r,
       newstatusdef (0, $ffff,
         newstatuskey (get_msg (17), kbf1, cmhelp,
         newstatuskey (get_msg (18), kbf2, cm_save,
         newstatuskey (get_msg (19), kbf3, cm_load,
         newstatuskey (get_msg (20), kbf10, cmmenu,
         newstatuskey (get_msg (21), kbaltx, cm_quit,
         nil))))),
       nil)
     ));
end; { O_Prg.InitStatusLine }
{
**************************************************************************
}
function o_prg.GetPalette: PPalette;
const
     CNewColor = CColor + CHelpColor;
     CNewBlackWhite = CBlackWhite + CHelpBlackWhite;
     CNewMonochrome = CMonochrome + CHelpMonochrome;
     P : array [apColor..apMonochrome] of string [Length (CNewColor)] =
         (CNewColor, CNewBlackWhite, CNewMonochrome);
begin
  case PaletteCouleur of
    0 : GetPalette := @P [0];
    1 : GetPalette := @MesCouleurs [1];
    2 : GetPalette := @P [1];
    3 : GetPalette := @MesCouleurs [3];
    4 : GetPalette := @MesCouleurs [4];
  end;
end; { O_Prg.GetPalette }
{
**************************************************************************
}
procedure o_prg.handleevent (var event : tevent);

  function File_select (chemin : PathStr) : pathstr;
  var
     select : PFileDialog;
     ch,
     file_name : pathstr;
  begin
       select := New (PFileDialog, Init (chemin, get_msg (22), get_msg (23), fdOpenButton, 0));
       select^.HelpCtx := hcnocontext;
       if (ValidView (select) <> nil)
       then
           begin
                if (Desktop^.ExecView (select) <> cmCancel)
                then
                    begin
                         select^.GetFileName (File_Name);
                         ch := file_name;
                    end
                else
                    ch := '';
                {endif}
                Dispose (select, Done);
           end
       else
           ch := '';
       {endif}
       file_select := ch;
  end; { file_select }

  procedure select_file (var nom_data_fich : string);
  var
     dir : dirstr;
     name : namestr;
     ext : extstr;
  begin
       nom_data_fich := file_select ('*.IDF');
       if (nom_data_fich = '')
       then
           nom_data_fich := fexpand ('NONAME.IDF')
       else
           begin
                fsplit (fexpand (nom_data_fich), dir, name, ext);
                if ((ext <> '.IDF') and (ext <> '.idf'))
                then
                    name := 'NONAME';
                {endif}
                nom_data_fich := dir+name+'.IDF';
           end;
       {endif}
  end; { Select_File }

  procedure about_index;
  var
     boite : pdialog;
     r : trect;
     lig : pstatictext;
     button : pbutton;
     result : word;
  begin
       r.assign (19, 5, 61, 16);
       boite := new (pdialog, init (r, ''));
       boite^.helpctx := hcnocontext;
       r.assign (18, 1, 23, 2);
       lig := new (pstatictext, init (r, 'Index'));
       boite^.insert (lig);
       r.assign (15, 3, 26, 4);
       lig := new (pstatictext, init (r, get_msg (24)+' '+num_vers));
       boite^.insert (lig);
       r.assign (2, 5, 40, 6);
       lig := new (pstatictext, init (r, '(c) Patrick Pr‚martin ('+dat_vers+')'));
       boite^.insert (lig);
       r.assign (7, 7, 35, 8);
       lig := new (pstatictext, init (r, '(c) Olf Software 1992'));
       boite^.insert (lig);
       r.assign (16, 8, 24, 10);
       button := new (pbutton, init (r, get_msg (26), cmok, bfdefault));
       boite^.insert (button);
       if (validview (boite) <> nil)
       then
           begin
                result := desktop^.execview (boite);
                dispose (boite, done);
           end;
       {endif}
  end; { About_Index }

  procedure save_data_base;
  begin
       if (modif and (messagebox (get_msg (27), nil, mfyesbutton+mfnobutton+mfconfirmation) = cmyes))
       then
           begin
                if ((file_name = '')
                   or (cmyes <> messagebox (get_msg (28)+' '+file_name+' ?', nil, mfyesbutton+mfnobutton+mfconfirmation)))
                then
                    select_file (file_name);
                {endif}
                save_base (file_name);
           end;
       {endif}
  end; { Save_Data_Base }

  procedure load_data_base;
  begin
       if (messagebox (get_msg (29), nil, mfyesbutton+mfnobutton+mfconfirmation) = cmyes)
       then
           begin
                save_data_base;
                if ((file_name = '')
                   or (cmyes <> messagebox (get_msg (30)+' '+file_name+' ?', nil, mfyesbutton+mfnobutton+mfconfirmation)))
                then
                    select_file (file_name);
                {endif}
                load_base (file_name);
           end;
       {endif}
  end; { Load_Data_Base }

  procedure create_data_base;
  begin
       if (messagebox (get_msg (31), nil, mfyesbutton+mfnobutton+mfconfirmation) = cmyes)
       then
           begin
                save_data_base;
                select_file (file_name);
                create_base (file_name, self);
           end;
       {endif}
  end; { Create_Data_Base }

  procedure change_path;
  var
     Direct : PChDirDialog;
     result : word;
  begin
       Direct := New (PChDirDialog, Init (cdNormal, 101));
       Direct^.HelpCtx := hcnocontext;
       if (ValidView (Direct) <> nil)
       then
           begin
                result := DeskTop^.ExecView (Direct);
                Dispose (Direct, Done);
           end;
       {endif}
  end; { Change_Path }

  procedure Dos_Shell;
  var
     path_2 : string;
  begin
       getdir (0, path_2);
       DoneSysError;
       DoneEvents;
       DoneVideo;
       DoneMemory;
       SetMemTop (HeapPtr);
       printstr (get_msg (32)+' '+num_vers+' ...');
{$ifdef demo_vers}
       printstr (get_msg (33));
{$endif}
       SwapVectors;
       Exec (GetEnv ('COMSPEC'), '');
       SwapVectors;
       SetMemTop (HeapEnd);
       InitMemory;
       InitVideo;
       InitEvents;
       InitSysError;
       chdir (path_2);
       Redraw;
  end; { Dos_Shell }

  procedure edit_modify;
  var
     result : word;
  begin
       if activ
       then
         if (nb_enreg > 0)
         then
           idf_edit_modify (self)
         else
           result := messagebox (get_msg (34), nil, mferror+mfcancelbutton)
       else
           result := messagebox (get_msg (35), nil, mferror+mfcancelbutton);
       {endif}
  end; { Edit_Modify }

  procedure sort_base;
  var
     result : word;
  begin
    result := messagebox (get_msg (36), nil, mfcancelbutton);
(*
       if activ
       then
         if (nb_enreg > 0)
         then
           idf_sort_base (self)
         else
           result := messagebox (get_msg (34), nil, mferror+mfcancelbutton)
       else
           result := messagebox (get_msg (35), nil, mferror+mfcancelbutton);
       {endif}
*)
  end; { Sort_Base }

  procedure search_data;
  var
     result : word;
  begin
    result := messagebox (get_msg (36), nil, mfcancelbutton);
(*
       if activ
       then
         if (nb_enreg > 0)
         then
           idf_search_data (self)
         else
           result := messagebox (get_msg (34), nil, mferror+mfcancelbutton)
       else
           result := messagebox (get_msg (35), nil, mferror+mfcancelbutton);
       {endif}
*)
  end; { Search_Data }

  procedure insert_data;
  var
     result : word;
  begin
       if activ
       then
           idf_insert_data (self)
       else
           result := messagebox (get_msg (35), nil, mferror+mfcancelbutton);
       {endif}
  end; { Insert_Data }

begin
     tapplication.handleevent (event);
     if (event.what = evcommand)
     then
         case event.command of
              cm_about : about_index;
              cm_save : save_data_base;
              cm_load : load_data_base;
              cm_create : create_data_base;
              cm_directory : change_path;
              cm_date : change_date (self);
              cm_time : change_time (self);
              cm_couleur : begin
                changepalette (PaletteCouleur, ShowMarkers);
                donememory;
                initmemory;
                redraw;
              end;
              cm_dos : dos_shell;
              cm_edit_modify : edit_modify;
              cm_sort : sort_base;
              cm_search : search_data;
              cm_insert : insert_data;
              cm_quit : begin
                             save_data_base;
                             endmodal (cmquit);
              end;
         end;
     {endif}
end; { O_Prg.HandleEvent }
{
**************************************************************************
}
procedure O_Prg.GetEvent (var Event : TEvent);
var
  w : PWindow;
  HFile : PHelpFile;
  HelpStrm : PDosStream;
const
  HelpInUse : boolean = false;
begin
  TApplication.GetEvent (Event);
  case Event.What of
    evCommand : if ((Event.Command = cmHelp) and not HelpInUse)
                then
                  begin
                    HelpInUse := true;
                    HelpStrm := new (PDosStream, init (Get_File_Name (get_msg (37)), stOpenRead));
                    HFile := new (PHelpFile, init (HelpStrm));
                    if (HelpStrm^.Status <> stOK)
                    then
                      res := messagebox (get_msg (38), nil, mfError+mfOkButton)
                    else
                      begin
                        w := new (PHelpWindow, init (HFile, GetHelpCtx));
                        if (validview (w) <> nil)
                        then
                          begin
                            res := execview (w);
                            dispose (w, done);
                          end;
                        {endif}
                      end;
                    {endif}
                    clearevent (event);
                    helpinuse := false;
                  end;
                {endif}
  end;
end; { O_Prg.GetEvent }
{
**************************************************************************
}
var
   ndx4 : o_prg;

begin
     C_EXE_Name := 'INDEX4.EXE';
{$ifdef demo_vers}
     init_olf_message (mess_demo);
     init_licence ('DEMONDX4');
{$else}
     init_olf_message (mess_shareware);
     init_licence ('NDX4');
{$endif}
     init_olf_software ('Index '+num_vers, #155' Patrick Premartin '+dat_vers);
     show_mouse;
     ndx4.init;
     ndx4.run;
     ndx4.done;
     writeln (get_msg (39)+' '+num_vers);
{$ifdef demo_vers}
     writeln (get_msg (40));
     writeln (get_msg (41));
     writeln;
     writeln (get_msg (42));
     writeln ('                    PREMARTIN PATRICK');
     writeln ('                    LOT. LE SOULEIADO');
     writeln ('                      13790 ROUSSET');
     writeln ('                         FRANCE');
     writeln (get_msg (43));
{$endif}
end.
