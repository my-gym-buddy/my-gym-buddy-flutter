import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/helper.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/models/set_row.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_checkbox.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_text_field.dart';

class SetRow extends StatefulWidget {
  const SetRow(
      {super.key,
      required this.setIndex,
      required this.index,
      required this.selectedExercises,
      required this.isEditable,
      required this.refresh,
      this.isActiveWorkout = false});

  final bool? isEditable;
  final Function? refresh;
  final bool? isActiveWorkout;
  final int setIndex;
  final int index;
  final List<Exercise> selectedExercises;

  @override
  _SetRowState createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> with SingleTickerProviderStateMixin {
  late final SlidableController _slidableController;

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
  }

  @override
  void dispose() {
    _slidableController.dispose();
    super.dispose();
  }

  // Create model instance
  SetRowModel get _model => SetRowModel(
        selectedExercises: widget.selectedExercises,
        setIndex: widget.setIndex,
        index: widget.index,
        isEditable: widget.isEditable,
        refresh: widget.refresh,
        isActiveWorkout: widget.isActiveWorkout,
      );

  String getPreviousWeight() {
    return _model.getPreviousWeight();
  }

  @override
  Widget build(BuildContext context) {
    // Handle header row case
    if (widget.setIndex == -1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: Center(child: Text('set'))),
          const Expanded(flex: 4, child: Center(child: Text('previous'))),
          Expanded(
              flex: 4,
              child: Center(child: Text('+${Config.getUnitAbbreviation()}'))),
          const Expanded(flex: 4, child: Center(child: Text('reps'))),
          const Expanded(flex: 2, child: Center(child: Text(''))),
        ],
      );
    }

    // Safety check for invalid index
    if (widget.index >= widget.selectedExercises.length) {
      return const SizedBox(); // Return empty widget if index is invalid
    }

    // Handle editable set row with Slidable
    if (widget.isEditable != null) {
      return Slidable(
        controller: _slidableController,
        endActionPane: ActionPane(
          extentRatio: 0.25,
          motion: const ScrollMotion(),
          children: [
            Expanded(
              child: atsIconButton(
                  icon: const Icon(Icons.delete),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  onPressed: () {
                    if (widget.index < widget.selectedExercises.length &&
                        widget.setIndex <
                            widget
                                .selectedExercises[widget.index].sets.length) {
                      widget.selectedExercises[widget.index].sets
                          .removeAt(widget.setIndex);
                      _slidableController.close();
                      widget.refresh!();
                    }
                  }),
            )
          ],
        ),
        child: _buildSetRow(context),
      );
    }

    // Handle non-editable set row
    return _buildSetRow(context);
  }

  // Extract the row content to a separate method
  Widget _buildSetRow(BuildContext context) {
    // Safety check for invalid indices
    if (!_model.areIndicesValid()) {
      return const SizedBox();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSetNumberCell(),
        _buildPreviousWeightCell(),
        _buildWeightInputField(),
        _buildRepsInputField(),
        Expanded(flex: 2, child: _buildCompletionCheckbox()),
      ],
    );
  }

  // Build set number cell
  Widget _buildSetNumberCell() {
    return Expanded(child: Center(child: Text('${widget.setIndex + 1}')));
  }

  // Build previous weight cell
  Widget _buildPreviousWeightCell() {
    return Expanded(
      flex: 4,
      child: Center(
        child: GestureDetector(
          onTap: () => _model.copyFromPreviousSet(),
          child: Text(getPreviousWeight()),
        ),
      ),
    );
  }

  // Build weight input field
  Widget _buildWeightInputField() {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 30,
          child: atsTextField(
            selectAllOnTap: true,
            textEditingController: TextEditingController(
                text: Helper.getWeightInCorrectUnit(widget
                        .selectedExercises[widget.index]
                        .sets[widget.setIndex]
                        .weight)
                    .toStringAsFixed(1)),
            textAlign: TextAlign.center,
            labelText: '',
            keyboardType: TextInputType.number,
            enabled: widget.isEditable != null,
            onChanged: (value) => _model.updateWeight(value),
          ),
        ),
      ),
    );
  }

  // Build reps input field
  Widget _buildRepsInputField() {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 30,
          child: atsTextField(
            selectAllOnTap: true,
            textEditingController: TextEditingController(
                text: widget
                    .selectedExercises[widget.index].sets[widget.setIndex].reps
                    .toString()),
            textAlign: TextAlign.center,
            labelText: '',
            keyboardType: TextInputType.number,
            onChanged: (value) => _model.updateReps(value),
            enabled: widget.isEditable != null,
          ),
        ),
      ),
    );
  }

  // Build the completion checkbox
  Widget _buildCompletionCheckbox() {
    if (widget.isActiveWorkout != true) return const SizedBox();

    return atsCheckbox(
      checked: _model.areIndicesValid()
          ? widget
              .selectedExercises[widget.index].sets[widget.setIndex].completed
          : false,
      onChanged: _model.handleCheckboxChanged,
    );
  }
}
