import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sign_pain_admin/model/pain_descriptor_data.dart';
import 'package:sign_pain_admin/theme/app_colors.dart';
import 'package:sign_pain_admin/viewmodel/pain_descriptor_view_model.dart';

class PainDescriptorsScreen extends StatefulWidget {
  const PainDescriptorsScreen({super.key, required this.title});

  final String title;

  @override
  State<PainDescriptorsScreen> createState() => _PainDescriptorsScreenState();
}

class _PainDescriptorsScreenState extends State<PainDescriptorsScreen> {
  final painDescriptorViewModel = PainDescriptorViewModel();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController symbolController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final LayerLink _layerLink = LayerLink(); // Connects TextField to Overlay
  OverlayEntry? _overlayEntry; // Reference to show/remove the floating picker
  bool _isPickerOpen = false;

  @override
  void initState() {
    super.initState();
    try {
      painDescriptorViewModel.getPainDescriptors();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    symbolController.dispose();
    descriptionController.dispose();
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        title: Text(widget.title, style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface)),
        centerTitle: true
      ),
      body: ListenableBuilder(
        listenable: painDescriptorViewModel,
        builder: (context, child) {
          if (painDescriptorViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          else {
            final painDescriptors = painDescriptorViewModel.painDescriptors;

            return Row(
              children: [
                Expanded(
                  flex: 40,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16), // Padding around the whole list
                    itemCount: painDescriptors.length,
                    itemBuilder: (context, index) {
                      final item = painDescriptors[index];

                      return Card(
                        elevation: 2, // Subtle drop shadow
                        shadowColor: Colors.black12,
                        margin: const EdgeInsets.only(bottom: 12), // Spacing between items
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), // Smooth rounded corners
                          side: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          
                          // leads with the symbol associated with the pain type
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              item.associatedSymbol, 
                              style: TextStyle(fontSize: 20)
                            )
                          ),

                          title: Text(
                            item.descriptorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),

                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey,
                          ),

                          onTap: () => _showDetailsDialog(context, item),
                        ),
                      );
                    },
                  )
                ),
                Expanded(
                  flex: 60,
                  child: Padding(
                    padding: const .symmetric(horizontal: 32, vertical: 32),
                    child: Column(
                      mainAxisAlignment: .spaceEvenly,
                      children: [
                        Text("Adicionar novo descritor de dor", style: TextStyle(fontSize: 26, fontWeight: .bold)),
                        TextField(
                          controller: nameController,
                          obscureText: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelText: 'Descritor',
                          ),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next
                        ),
                        CompositedTransformTarget(
                          link: _layerLink,
                          child: TextField(
                            controller: symbolController,
                            obscureText: false,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: 'Símbolo',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPickerOpen ? Icons.keyboard_hide : Icons.emoji_emotions_outlined,
                                  color: _isPickerOpen ? Theme.of(context).primaryColor : Colors.grey,
                                ),
                                onPressed: _toggleEmojiPicker
                              ),
                            ),
                            maxLength: 1,
                            style: const TextStyle(fontSize: 24),
                            textInputAction: TextInputAction.next,
                            onChanged: (val) {
                              // Keep only the last typed character if they paste multiple
                              if (val.characters.length > 1) {
                                symbolController.text = val.characters.last;
                                symbolController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: symbolController.text.length)
                                );
                              }
                            }
                          )
                        ),
                        TextField(
                          controller: descriptionController,
                          obscureText: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelText: 'Descreve este tipo de dor',
                          ),
                          keyboardType: TextInputType.text,
                          minLines: 3,
                          maxLines: null,
                          textAlignVertical: .top,
                        ),
                        Text("INSERIR CAIXA DE VIDEO"),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await painDescriptorViewModel.createNewPainDescriptor(nameController.text, symbolController.text, descriptionController.text);

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${nameController.text} adicionado!")));

                              nameController.clear();
                              symbolController.clear();
                              descriptionController.clear();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          }, 
                          child: Text("Guardar")
                        )
                      ]
                    )
                  )
                )
              ],
            );
          }
        },
      )
    );
  }

  // dialog which shows the pain descriptors info 
  void _showDetailsDialog(BuildContext context, PainDescriptorData painDescriptorData) {
    final dialogWidth = MediaQuery.widthOf(context)*0.4;
    final dialogHeight = MediaQuery.heightOf(context)* 0.6;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          scrollable: true,
          title: Center(child: Text("${painDescriptorData.descriptorName} ${painDescriptorData.associatedSymbol}")),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: dialogHeight
            ),
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: "ID: ",
                            style: TextStyle(fontWeight: .bold)
                          ),
                          TextSpan(
                            text: painDescriptorData.id
                          )
                        ]
                      )
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: "Video: ",
                            style: TextStyle(fontWeight: .bold)
                          ),
                          TextSpan(
                            text: painDescriptorData.videoURL
                          )
                        ]
                      )
                    ),
                    SizedBox(height: 20),
                    Text(painDescriptorData.description),
                  ]
                )
              )
            )
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Fechar", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  void _toggleEmojiPicker() {
    if (_isPickerOpen) {
      _hideOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isPickerOpen = true;
    });
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isPickerOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 320, // Width of floating picker
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60), // Y-offset to place it below the TextField
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: EmojiPicker(
                  textEditingController: symbolController,
                  onEmojiSelected: (category, emoji) {
                    _hideOverlay(); // Automatically close overlay after selecting
                  },
                  config: const Config(
                    height: 280,
                    emojiViewConfig: EmojiViewConfig(columns: 8),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}