pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b~client.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b~client.adb");
pragma Suppress (Overflow_Check);
with Ada.Exceptions;

package body ada_main is

   E062 : Short_Integer; pragma Import (Ada, E062, "system__os_lib_E");
   E018 : Short_Integer; pragma Import (Ada, E018, "ada__exceptions_E");
   E014 : Short_Integer; pragma Import (Ada, E014, "system__soft_links_E");
   E012 : Short_Integer; pragma Import (Ada, E012, "system__exception_table_E");
   E037 : Short_Integer; pragma Import (Ada, E037, "ada__containers_E");
   E057 : Short_Integer; pragma Import (Ada, E057, "ada__io_exceptions_E");
   E027 : Short_Integer; pragma Import (Ada, E027, "ada__numerics_E");
   E009 : Short_Integer; pragma Import (Ada, E009, "ada__strings_E");
   E096 : Short_Integer; pragma Import (Ada, E096, "ada__strings__maps_E");
   E099 : Short_Integer; pragma Import (Ada, E099, "ada__strings__maps__constants_E");
   E042 : Short_Integer; pragma Import (Ada, E042, "interfaces__c_E");
   E021 : Short_Integer; pragma Import (Ada, E021, "system__exceptions_E");
   E073 : Short_Integer; pragma Import (Ada, E073, "system__object_reader_E");
   E049 : Short_Integer; pragma Import (Ada, E049, "system__dwarf_lines_E");
   E092 : Short_Integer; pragma Import (Ada, E092, "system__soft_links__initialize_E");
   E036 : Short_Integer; pragma Import (Ada, E036, "system__traceback__symbolic_E");
   E189 : Short_Integer; pragma Import (Ada, E189, "ada__assertions_E");
   E109 : Short_Integer; pragma Import (Ada, E109, "ada__strings__utf_encoding_E");
   E117 : Short_Integer; pragma Import (Ada, E117, "ada__tags_E");
   E107 : Short_Integer; pragma Import (Ada, E107, "ada__strings__text_buffers_E");
   E105 : Short_Integer; pragma Import (Ada, E105, "ada__streams_E");
   E133 : Short_Integer; pragma Import (Ada, E133, "system__file_control_block_E");
   E132 : Short_Integer; pragma Import (Ada, E132, "system__finalization_root_E");
   E130 : Short_Integer; pragma Import (Ada, E130, "ada__finalization_E");
   E129 : Short_Integer; pragma Import (Ada, E129, "system__file_io_E");
   E175 : Short_Integer; pragma Import (Ada, E175, "system__storage_pools_E");
   E179 : Short_Integer; pragma Import (Ada, E179, "system__finalization_masters_E");
   E177 : Short_Integer; pragma Import (Ada, E177, "system__storage_pools__subpools_E");
   E153 : Short_Integer; pragma Import (Ada, E153, "ada__strings__unbounded_E");
   E103 : Short_Integer; pragma Import (Ada, E103, "ada__text_io_E");
   E191 : Short_Integer; pragma Import (Ada, E191, "system__pool_global_E");
   E169 : Short_Integer; pragma Import (Ada, E169, "sgf_E");

   Sec_Default_Sized_Stacks : array (1 .. 1) of aliased System.Secondary_Stack.SS_Stack (System.Parameters.Runtime_Default_Sec_Stack_Size);

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   Is_Elaborated : Boolean := False;

   procedure finalize_library is
   begin
      E169 := E169 - 1;
      declare
         procedure F1;
         pragma Import (Ada, F1, "sgf__finalize_spec");
      begin
         F1;
      end;
      E191 := E191 - 1;
      declare
         procedure F2;
         pragma Import (Ada, F2, "system__pool_global__finalize_spec");
      begin
         F2;
      end;
      E103 := E103 - 1;
      declare
         procedure F3;
         pragma Import (Ada, F3, "ada__text_io__finalize_spec");
      begin
         F3;
      end;
      E153 := E153 - 1;
      declare
         procedure F4;
         pragma Import (Ada, F4, "ada__strings__unbounded__finalize_spec");
      begin
         F4;
      end;
      E177 := E177 - 1;
      declare
         procedure F5;
         pragma Import (Ada, F5, "system__storage_pools__subpools__finalize_spec");
      begin
         F5;
      end;
      E179 := E179 - 1;
      declare
         procedure F6;
         pragma Import (Ada, F6, "system__finalization_masters__finalize_spec");
      begin
         F6;
      end;
      declare
         procedure F7;
         pragma Import (Ada, F7, "system__file_io__finalize_body");
      begin
         E129 := E129 - 1;
         F7;
      end;
      declare
         procedure Reraise_Library_Exception_If_Any;
            pragma Import (Ada, Reraise_Library_Exception_If_Any, "__gnat_reraise_library_exception_if_any");
      begin
         Reraise_Library_Exception_If_Any;
      end;
   end finalize_library;

   procedure adafinal is
      procedure s_stalib_adafinal;
      pragma Import (Ada, s_stalib_adafinal, "system__standard_library__adafinal");

      procedure Runtime_Finalize;
      pragma Import (C, Runtime_Finalize, "__gnat_runtime_finalize");

   begin
      if not Is_Elaborated then
         return;
      end if;
      Is_Elaborated := False;
      Runtime_Finalize;
      s_stalib_adafinal;
   end adafinal;

   type No_Param_Proc is access procedure;
   pragma Favor_Top_Level (No_Param_Proc);

   procedure adainit is
      Main_Priority : Integer;
      pragma Import (C, Main_Priority, "__gl_main_priority");
      Time_Slice_Value : Integer;
      pragma Import (C, Time_Slice_Value, "__gl_time_slice_val");
      WC_Encoding : Character;
      pragma Import (C, WC_Encoding, "__gl_wc_encoding");
      Locking_Policy : Character;
      pragma Import (C, Locking_Policy, "__gl_locking_policy");
      Queuing_Policy : Character;
      pragma Import (C, Queuing_Policy, "__gl_queuing_policy");
      Task_Dispatching_Policy : Character;
      pragma Import (C, Task_Dispatching_Policy, "__gl_task_dispatching_policy");
      Priority_Specific_Dispatching : System.Address;
      pragma Import (C, Priority_Specific_Dispatching, "__gl_priority_specific_dispatching");
      Num_Specific_Dispatching : Integer;
      pragma Import (C, Num_Specific_Dispatching, "__gl_num_specific_dispatching");
      Main_CPU : Integer;
      pragma Import (C, Main_CPU, "__gl_main_cpu");
      Interrupt_States : System.Address;
      pragma Import (C, Interrupt_States, "__gl_interrupt_states");
      Num_Interrupt_States : Integer;
      pragma Import (C, Num_Interrupt_States, "__gl_num_interrupt_states");
      Unreserve_All_Interrupts : Integer;
      pragma Import (C, Unreserve_All_Interrupts, "__gl_unreserve_all_interrupts");
      Detect_Blocking : Integer;
      pragma Import (C, Detect_Blocking, "__gl_detect_blocking");
      Default_Stack_Size : Integer;
      pragma Import (C, Default_Stack_Size, "__gl_default_stack_size");
      Default_Secondary_Stack_Size : System.Parameters.Size_Type;
      pragma Import (C, Default_Secondary_Stack_Size, "__gnat_default_ss_size");
      Bind_Env_Addr : System.Address;
      pragma Import (C, Bind_Env_Addr, "__gl_bind_env_addr");

      procedure Runtime_Initialize (Install_Handler : Integer);
      pragma Import (C, Runtime_Initialize, "__gnat_runtime_initialize");

      Finalize_Library_Objects : No_Param_Proc;
      pragma Import (C, Finalize_Library_Objects, "__gnat_finalize_library_objects");
      Binder_Sec_Stacks_Count : Natural;
      pragma Import (Ada, Binder_Sec_Stacks_Count, "__gnat_binder_ss_count");
      Default_Sized_SS_Pool : System.Address;
      pragma Import (Ada, Default_Sized_SS_Pool, "__gnat_default_ss_pool");

   begin
      if Is_Elaborated then
         return;
      end if;
      Is_Elaborated := True;
      Main_Priority := -1;
      Time_Slice_Value := -1;
      WC_Encoding := 'b';
      Locking_Policy := ' ';
      Queuing_Policy := ' ';
      Task_Dispatching_Policy := ' ';
      Priority_Specific_Dispatching :=
        Local_Priority_Specific_Dispatching'Address;
      Num_Specific_Dispatching := 0;
      Main_CPU := -1;
      Interrupt_States := Local_Interrupt_States'Address;
      Num_Interrupt_States := 0;
      Unreserve_All_Interrupts := 0;
      Detect_Blocking := 0;
      Default_Stack_Size := -1;

      ada_main'Elab_Body;
      Default_Secondary_Stack_Size := System.Parameters.Runtime_Default_Sec_Stack_Size;
      Binder_Sec_Stacks_Count := 1;
      Default_Sized_SS_Pool := Sec_Default_Sized_Stacks'Address;

      Runtime_Initialize (1);

      Finalize_Library_Objects := finalize_library'access;

      Ada.Exceptions'Elab_Spec;
      System.Soft_Links'Elab_Spec;
      System.Exception_Table'Elab_Body;
      E012 := E012 + 1;
      Ada.Containers'Elab_Spec;
      E037 := E037 + 1;
      Ada.Io_Exceptions'Elab_Spec;
      E057 := E057 + 1;
      Ada.Numerics'Elab_Spec;
      E027 := E027 + 1;
      Ada.Strings'Elab_Spec;
      E009 := E009 + 1;
      Ada.Strings.Maps'Elab_Spec;
      E096 := E096 + 1;
      Ada.Strings.Maps.Constants'Elab_Spec;
      E099 := E099 + 1;
      Interfaces.C'Elab_Spec;
      E042 := E042 + 1;
      System.Exceptions'Elab_Spec;
      E021 := E021 + 1;
      System.Object_Reader'Elab_Spec;
      E073 := E073 + 1;
      System.Dwarf_Lines'Elab_Spec;
      E049 := E049 + 1;
      System.Os_Lib'Elab_Body;
      E062 := E062 + 1;
      System.Soft_Links.Initialize'Elab_Body;
      E092 := E092 + 1;
      E014 := E014 + 1;
      System.Traceback.Symbolic'Elab_Body;
      E036 := E036 + 1;
      E018 := E018 + 1;
      Ada.Assertions'Elab_Spec;
      E189 := E189 + 1;
      Ada.Strings.Utf_Encoding'Elab_Spec;
      E109 := E109 + 1;
      Ada.Tags'Elab_Spec;
      Ada.Tags'Elab_Body;
      E117 := E117 + 1;
      Ada.Strings.Text_Buffers'Elab_Spec;
      E107 := E107 + 1;
      Ada.Streams'Elab_Spec;
      E105 := E105 + 1;
      System.File_Control_Block'Elab_Spec;
      E133 := E133 + 1;
      System.Finalization_Root'Elab_Spec;
      E132 := E132 + 1;
      Ada.Finalization'Elab_Spec;
      E130 := E130 + 1;
      System.File_Io'Elab_Body;
      E129 := E129 + 1;
      System.Storage_Pools'Elab_Spec;
      E175 := E175 + 1;
      System.Finalization_Masters'Elab_Spec;
      System.Finalization_Masters'Elab_Body;
      E179 := E179 + 1;
      System.Storage_Pools.Subpools'Elab_Spec;
      E177 := E177 + 1;
      Ada.Strings.Unbounded'Elab_Spec;
      E153 := E153 + 1;
      Ada.Text_Io'Elab_Spec;
      Ada.Text_Io'Elab_Body;
      E103 := E103 + 1;
      System.Pool_Global'Elab_Spec;
      E191 := E191 + 1;
      sgf'elab_spec;
      E169 := E169 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_client");

   function main
     (argc : Integer;
      argv : System.Address;
      envp : System.Address)
      return Integer
   is
      procedure Initialize (Addr : System.Address);
      pragma Import (C, Initialize, "__gnat_initialize");

      procedure Finalize;
      pragma Import (C, Finalize, "__gnat_finalize");
      SEH : aliased array (1 .. 2) of Integer;

      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      if gnat_argc = 0 then
         gnat_argc := argc;
         gnat_argv := argv;
      end if;
      gnat_envp := envp;

      Initialize (SEH'Address);
      adainit;
      Ada_Main_Program;
      adafinal;
      Finalize;
      return (gnat_exit_status);
   end;

--  BEGIN Object file/option list
   --   ./sgf.o
   --   ./client.o
   --   -L./
   --   -L/usr/lib/gcc/x86_64-linux-gnu/14/adalib/
   --   -shared
   --   -lgnat-14
   --   -ldl
--  END Object file/option list   

end ada_main;
