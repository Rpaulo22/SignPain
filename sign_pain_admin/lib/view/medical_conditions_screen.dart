import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter/material.dart';
import 'package:sign_pain_admin/model/medical_condition_data.dart';
import 'package:sign_pain_admin/theme/app_colors.dart';
import 'package:sign_pain_admin/utils/body_parts_mapper.dart';
import 'package:sign_pain_admin/viewmodel/medical_condition_view_model.dart';
import 'package:sign_pain_admin/viewmodel/pain_descriptor_view_model.dart';
import 'package:sign_pain_admin/widgets/pain_descriptor_widget.dart';

class MedicalConditionsScreen extends StatefulWidget {
  const MedicalConditionsScreen({super.key, required this.title});

  final String title;

  @override
  State<MedicalConditionsScreen> createState() => _MedicalConditionsScreenState();
}

class _MedicalConditionsScreenState extends State<MedicalConditionsScreen> {
  final painDescriptorViewModel = PainDescriptorViewModel();
  final medicalConditionViewModel = MedicalConditionViewModel();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController causesController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();
  final List<String> commonDescriptors = [];
  final List<String> uncommonDescriptors = [];
  var bodyFront = BodyParts();
  var bodyBack = BodyParts();

  @override
  void initState() {
    super.initState();
    try {
      painDescriptorViewModel.getPainDescriptors();
      medicalConditionViewModel.getMedicalConditions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    treatmentController.dispose();
    descriptionController.dispose();
    causesController.dispose();
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
        // listen to both view models, making sure they load before 
        listenable: Listenable.merge([
          painDescriptorViewModel,
          medicalConditionViewModel,
        ]),
        builder: (context, child) {
          if (medicalConditionViewModel.isLoading || painDescriptorViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          else {
            final medicalConditions = medicalConditionViewModel.medicalConditions;
            final painDescriptors = painDescriptorViewModel.painDescriptors;

            // lists holding the information of the selected pain descriptors (which are saved by their ids solely)
            final commonPainDescriptors = painDescriptors.where((item) => commonDescriptors.contains(item.id)).toList();
            final uncommonPainDescriptors = painDescriptors.where((item) => uncommonDescriptors.contains(item.id)).toList();


            return Row(
              children: [
                Expanded(
                  flex: 40,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16), // Padding around the whole list
                    itemCount: medicalConditions.length,
                    itemBuilder: (context, index) {
                      final item = medicalConditions[index];

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
                            child: Icon(
                              Icons.medical_information
                            )
                          ),

                          title: Text(
                            item.name,
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
                        const Text(
                          "Adicionar nova condição", 
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                // condition name field
                                TextField(
                                  controller: nameController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    labelText: 'Nome da condição',
                                  ),
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next
                                ),
                                const SizedBox(height: 30),

                                // condition's description field
                                TextField(
                                  controller: descriptionController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    labelText: 'Descreve esta condição',
                                  ),
                                  keyboardType: TextInputType.text,
                                  minLines: 3,
                                  maxLines: null,
                                  textAlignVertical: .top,
                                ),
                                const SizedBox(height: 30),

                                // condition's causes field
                                TextField(
                                  controller: causesController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    labelText: 'O que causa esta condição?',
                                  ),
                                  keyboardType: TextInputType.text,
                                  minLines: 3,
                                  maxLines: null,
                                  textAlignVertical: .top,
                                ),
                                const SizedBox(height: 30),

                                // common pain descriptors for the condition
                                const Text("Descritores comuns associados", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: [
                                    ...commonPainDescriptors.map((descriptor) {
                                      return Chip(
                                        avatar: Text(descriptor.associatedSymbol), // Shows the emoji
                                        label: Text(descriptor.descriptorName),
                                        deleteIcon: const Icon(Icons.close, size: 18),
                                        onDeleted: () {
                                          // Allows removing a descriptor without reopening the dialog
                                          setState(() {
                                            commonDescriptors.remove(descriptor.id);
                                          });
                                        },
                                      );
                                    }),
                                    
                                    ActionChip(
                                      avatar: const Icon(Icons.add),
                                      label: const Text("Adicionar"),
                                      backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
                                      onPressed: () => _openDescriptorSelectionDialog(commonDescriptors),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),

                                // uncommon pain descriptors for the condition
                                const Text("Descritores menos comuns associados", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: [
                                    ...uncommonPainDescriptors.map((descriptor) {
                                      return Chip(
                                        avatar: Text(descriptor.associatedSymbol), // Shows the emoji
                                        label: Text(descriptor.descriptorName),
                                        deleteIcon: const Icon(Icons.close, size: 18),
                                        onDeleted: () {
                                          // Allows removing a descriptor without reopening the dialog
                                          setState(() {
                                            uncommonDescriptors.remove(descriptor.id);
                                          });
                                        },
                                      );
                                    }),
                                    
                                    ActionChip(
                                      avatar: const Icon(Icons.add),
                                      label: const Text("Adicionar"),
                                      backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
                                      onPressed: () => _openDescriptorSelectionDialog(uncommonDescriptors),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),

                                // condition's common treatment field
                                TextField(
                                  controller: treatmentController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    labelText: 'Como se pode tratar esta condição?',
                                  ),
                                  keyboardType: TextInputType.text,
                                  minLines: 3,
                                  maxLines: null,
                                  textAlignVertical: .top,
                                ),
                                const SizedBox(height: 30),

                                SizedBox(
                                  height: 350,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: SafeArea(
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // The body map fills the background
                                              BodyPartSelector(
                                                bodyParts: bodyFront,
                                                onSelectionUpdated: _onFrontUpdated,
                                                side: BodySide.front
                                              ),
                                              const Positioned(
                                                bottom: 0,
                                                child: Text("Frente", style: TextStyle(fontWeight: FontWeight.bold))
                                              )
                                            ]
                                          )
                                        )
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: SafeArea(
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              BodyPartSelector(
                                                bodyParts: bodyBack,
                                                onSelectionUpdated: _onBackUpdated,
                                                side: BodySide.back
                                              ),
                                              const Positioned(
                                                bottom: 0,
                                                child: Text("Trás", style: TextStyle(fontWeight: FontWeight.bold))
                                              )
                                            ]
                                          )
                                        )
                                      )
                                    ]
                                  )
                                ),
                                SizedBox(height: 50),
                                Text("INSERIR CAIXAS DE VIDEOS", style: TextStyle(fontWeight: .bold, fontSize: 16)),
                              ]
                            )
                          )
                        ),

                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await medicalConditionViewModel.createNewMedicalCondition(
                                nameController.text, 
                                descriptionController.text, 
                                causesController.text, 
                                commonDescriptors, 
                                uncommonDescriptors, 
                                treatmentController.text,
                                BodyPartsMapper.toListBackAndFront(bodyBack, bodyFront)
                              );

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${nameController.text} adicionado!")));

                              nameController.clear();
                              causesController.clear();
                              descriptionController.clear();
                              treatmentController.clear();
                              commonDescriptors.clear();
                              uncommonDescriptors.clear();
                              bodyFront = BodyParts();
                              bodyBack = BodyParts();
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
  void _showDetailsDialog(BuildContext context, MedicalConditionData medData) {
    final painDescriptorsData = painDescriptorViewModel.painDescriptors;

    final commonDescriptorsData = painDescriptorsData.where((descriptor) => medData.commonDescriptors.contains(descriptor.id));
    final uncommonDescriptorsData = painDescriptorsData.where((descriptor) => medData.uncommonDescriptors.contains(descriptor.id));
    
    // BodyParts objects which hold the body parts affected by the condition for visualization purposes, front and back
    BodyParts partsFront = BodyPartsMapper.frontFromList(medData.bodyPartsAffected); 
    BodyParts partsBack = BodyPartsMapper.backFromList(medData.bodyPartsAffected); 

    showDialog( 
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          scrollable: true,
          title: Center(child: Text(medData.name)),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              }, 
              icon: Icon(Icons.close)
            )
          ],
          content: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.onSurface),
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05), // Very soft modern shadow
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .start,
              children: [
                Text(
                  medData.name, 
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                  textAlign: .start,
                ),

                Text(
                  medData.description,
                  textAlign: .start,
                  style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w600
                  )
                ),
                const SizedBox(height:25),

                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Causas\n",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: .bold
                        )
                      ),
                      TextSpan(
                        text: medData.causes,
                        style: TextStyle(
                          fontSize: 16
                        )
                      )
                    ]
                  )
                ),
                const SizedBox(height: 15),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0, right: 8.0), // Align text with the first chip
                      child: Text("Dor", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 8.0,    // Horizontal gap between tags
                        runSpacing: 8.0, // Vertical gap between lines
                        children: commonDescriptorsData.map((pd) {
                          return PainDescriptorWidget(painDescriptorData: pd);
                        }).toList(),
                      )
                    )
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0, right: 8.0), // Align text with the first chip
                      child: Text("Raramente", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 8.0,    // Horizontal gap between tags
                        runSpacing: 8.0, // Vertical gap between lines
                        children: uncommonDescriptorsData.map((pd) {
                          return PainDescriptorWidget(painDescriptorData: pd, isCommon: false);
                        }).toList(),
                      )
                    )
                  ],
                ),
                const SizedBox(height: 15),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Tratamento\n",
                        style: TextStyle(
                          fontWeight: .bold,
                          fontSize: 18
                        )
                      ),
                      TextSpan(
                        text: medData.treatment,
                        style: TextStyle(
                          fontSize: 15
                        )
                      )
                    ]
                  )
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 400,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: SafeArea(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // The body map fills the background
                              BodyPartSelector(
                                bodyParts: partsFront,
                                onSelectionUpdated: (_) {},
                                side: BodySide.front
                              ),
                              const Positioned(
                                bottom: 35,
                                child: Text("Frente", style: TextStyle(fontWeight: FontWeight.bold))
                              )
                            ]
                          )
                        )
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SafeArea(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              BodyPartSelector(
                                bodyParts: partsBack,
                                onSelectionUpdated: (_) {},
                                side: BodySide.back
                              ),
                              const Positioned(
                                bottom: 35,
                                child: Text("Trás", style: TextStyle(fontWeight: FontWeight.bold))
                              )
                            ]
                          )
                        )
                      )
                    ]
                  )
                ),
              ],
            )
          )
        );
      }
    );
  }

  void _openDescriptorSelectionDialog(List<String> selectedDescriptors) {
    
    // Get the full list of descriptors from the ViewModel
    final allDescriptors = painDescriptorViewModel.painDescriptors;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // StatefulBuilder allows the dialog to rebuild its own checkboxes
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Selecione os Descritores"),
              content: SizedBox(
                width: MediaQuery.widthOf(context) * 0.4,
                height: 400,
                child: ListView.builder(
                  itemCount: allDescriptors.length,
                  itemBuilder: (context, index) {
                    final item = allDescriptors[index];
                    final isSelected = selectedDescriptors.contains(item.id);

                    return CheckboxListTile(
                      title: Text("${item.associatedSymbol} ${item.descriptorName}"),
                      subtitle: Text(
                        item.description, 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: isSelected,
                      onChanged: (bool? checked) {
                        setDialogState(() {
                          if (checked == true) {
                            selectedDescriptors.add(item.id);
                          } else {
                            selectedDescriptors.remove(item.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    setState(() {});

                    Navigator.pop(context);
                  },
                  child: const Text("Confirmar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

   // Handles clicks on the front body
  void _onFrontUpdated(BodyParts updatedFront) {
    setState(() {
      // Accept all changes for the front
      bodyFront = updatedFront;

      // Mirror only the shared limbs to the back model
      bodyBack = bodyBack.copyWith(
        head: updatedFront.head,
        neck: updatedFront.neck,
        leftShoulder: updatedFront.leftShoulder,
        rightShoulder: updatedFront.rightShoulder,
        leftUpperArm: updatedFront.leftUpperArm,
        rightUpperArm: updatedFront.rightUpperArm,
        leftElbow: updatedFront.leftElbow,
        rightElbow: updatedFront.rightElbow,
        leftLowerArm: updatedFront.leftLowerArm,
        rightLowerArm: updatedFront.rightLowerArm,
        leftHand: updatedFront.leftHand,
        rightHand: updatedFront.rightHand,
        leftUpperLeg: updatedFront.leftUpperLeg,
        rightUpperLeg: updatedFront.rightUpperLeg,
        leftKnee: updatedFront.leftKnee,
        rightKnee: updatedFront.rightKnee,
        leftLowerLeg: updatedFront.leftLowerLeg,
        rightLowerLeg: updatedFront.rightLowerLeg,
        leftFoot: updatedFront.leftFoot,
        rightFoot: updatedFront.rightFoot
      );
    });
  }

  // Handles clicks on the back body
  void _onBackUpdated(BodyParts updatedBack) {
    setState(() {
      // Accept all changes for the back
      bodyBack = updatedBack;

      // Mirror only the shared limbs back to the front model
      bodyFront = bodyFront.copyWith(
        head: updatedBack.head,
        neck: updatedBack.neck,
        leftShoulder: updatedBack.leftShoulder,
        rightShoulder: updatedBack.rightShoulder,
        leftUpperArm: updatedBack.leftUpperArm,
        rightUpperArm: updatedBack.rightUpperArm,
        leftElbow: updatedBack.leftElbow,
        rightElbow: updatedBack.rightElbow,
        leftLowerArm: updatedBack.leftLowerArm,
        rightLowerArm: updatedBack.rightLowerArm,
        leftHand: updatedBack.leftHand,
        rightHand: updatedBack.rightHand,
        leftUpperLeg: updatedBack.leftUpperLeg,
        rightUpperLeg: updatedBack.rightUpperLeg,
        leftKnee: updatedBack.leftKnee,
        rightKnee: updatedBack.rightKnee,
        leftLowerLeg: updatedBack.leftLowerLeg,
        rightLowerLeg: updatedBack.rightLowerLeg,
        leftFoot: updatedBack.leftFoot,
        rightFoot: updatedBack.rightFoot
      );
    });
  }
}