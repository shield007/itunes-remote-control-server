Sequel.migration do
  up do
      create_table :tracks do
        primary_key :databaseId
        String :location
        String :name
        index :location, :unique=>true              
      end
      
      create_table :dead_tracks do
        primary_key :databaseId
        String :location
        String :name
      end
      
      create_table :dupe_tracks do
        primary_key :databaseId
        String :location
        String :name
      end
      
      create_table :params do
        primary_key :key
        String :value              
      end                       
  end
  down do
      drop_table(:tracks) 
      drop_table(:dead_tracks)
      drop_table(:params)
      drop_table(:value)
  end
end