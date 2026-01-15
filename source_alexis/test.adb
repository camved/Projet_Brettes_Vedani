with SGF; use SGF;

   function findRoot (current_directory: in P_file) return P_file is

      VOID_POINTER_ERROR: exception;

   begin

      if current_directory = null then
         raise VOID_POINTER_ERROR;
      elsif current_directory.all.rep_parent = null then
         return current_directory;
      else
         return findRoot(current_directory.all.rep_parent);
      end if;
   
   end findRoot;