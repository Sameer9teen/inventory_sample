Inventory Management App (Flutter + Firebase) 
This is a simple Inventory Management application built using Flutter and Firebase Firestore.
The app allows users to:

* Add inventory items
* Edit existing items
* Delete items
* Search and filter items by name and category

The project were using the flow :
UI -> Provider -> Controller -> Firebase -> Model(using it for the data structure,converts the data from the controller(firestore))

 Technologies are used it:

* Flutter (UI framework)
* Dart (Programming language)
* Firebase Firestore (Database)
* Provider (State management)
* ShadCN UI (UI components)

App Architecture:
- UI: Displays data and handles user interaction
- Provider: Holds app state and the logic 
- Controller: Handles Firebase operations
- Model: Defines the data structure and maps Firestore data
- Firestore: Cloud database 

Data flow:

 app were starts in the main.dart were 
 1. void main() async {
  WidgetsFlutterBinding.ensureInitialized(); this were the line were the main function starts , widgetflutter binding  were this were using were the , communicates between the dart and flutter engine and also the flutter framework ,async also to access the platforms(android,ios,web) before the runapp()

2. final controller = InventoryController();
  final inventoryProvider = InventoryProvider(controller);  
  await inventoryProvider.initialize(); 

were the controller were the access of the firestore were the inventory provider were the acesss of the controller ,were the data loads before the ui starts 

3. Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: inventoryProvider,
 
 were the access and ui rebuilds by the context.watch and changenotifier

  4.  debugShowCheckedModeBanner: false,
            theme: Theme.of(context),
            builder: (context, child) => ShadAppBuilder(child: child!),
            home: const HomeScreen(),
          );
were the first screen and renders it the homescreen 


   ),
   
 5.     floatingActionButton: FloatingActionButton(
        onPressed: () async {
          provider.startAdd();
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddItemScreen()),
          );                   /// to the add item screen 
        },
        child: const Icon(Icons.add),
      ),
    );
  }

fab button ,moves to the additem screen,

6.  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>(); 
  calls it were using by the notifylistiners() 

7.  ShadButton(
              onPressed: provider.isSaving
                  ? null
                  : () async {
                      try {
                        await provider.save();
                        if (context.mounted) Navigator.of(context).pop();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save item: $e')),
                          );
                        }
                      }
                    },

  were the click of the save ,were provider were used,were provider were used for everything were for the 

  
 8. Future<void> save() async {                      /// method were the ,decides od the it 
    if (name.trim().isEmpty) throw Exception('Item name cannot be empty');   /// validation for fields
    final parsedQuantity = int.tryParse(quantity) ?? 0;
    _isSaving = true;
    notifyListeners();
    try {
      if (isEditing) {
        await updateItem(
          _editingItem!.id,
          name: name.trim(),
          quantity: parsedQuantity,
          description: description.trim(),
          category: category.isEmpty ? null : category.trim(),
        );
      } else {
        await addItem(
          name: name.trim(),
          quantity: parsedQuantity,
          description: description.trim(),
          category: category.isEmpty ? null : category.trim(),
        );
      }

decides the add or edit

9. void startAdd() {
    _editingItem = null;
    name = '';
    quantity = '0';
    description = '';
    category = '';
    notifyListeners();
  }

were the add operation process code line

 10. Future<void> addItem({
    required String name,
    int quantity = 0, 
    String? description,
    String? category,
  }) async {
    await _controller.addItem(
      name: name,
      quantity: quantity,
      description: description,
      category: category,
    );
    await initialize();
  }
add new inventory item to the firestore


11. final FirebaseFirestore _firestore = FirebaseFirestore.instance;  //connects to the firestore

 12. CollectionReference get _collection => _firestore.collection('inventory');  // choose to the fiirestore collection inventory 

 13. Future<List<Item>> fetchItems() async {
    final snapshot = await _collection.get();  
    return snapshot.docs.map(Item.fromFirestore).toList();  // from the firestore were converts the data to item model were the model used and fetch the items in controller to the provider by using it   
  }

 14. Future<void> initialize() async {
    _items = await _controller.fetchItems();   
    notifyListeners();        
  }

  were fetch items from the controller to the provider ,were notifylisteneres were used to rebuild the ui 

 15.  final provider = context.watch<InventoryProvider>();  were rebuild the ui of the homescreen ,were using this 




To Run it : 
1. Clone the repository
2. Run `flutter pub get`
3. Configure Firebase using FlutterFire CLI
4. Run the app using:
   flutter run 
