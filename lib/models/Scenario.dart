import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Scenario {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool requiresCustomization;

  Scenario({
    required this.title, 
    required this.description,
    required this.icon,
    required this.color,
    this.requiresCustomization = false,
  });
}

class ScenarioDetailPage extends StatefulWidget {
  final Scenario scenario;

  const ScenarioDetailPage({
    Key? key,
    required this.scenario,
  }) : super(key: key);

  @override
  _ScenarioDetailPageState createState() => _ScenarioDetailPageState();
}

class _ScenarioDetailPageState extends State<ScenarioDetailPage> {
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();

  String _player1Side = 'Heads';
  String _player2Side = 'Tails';
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _player1Controller.addListener(_validateInput);
    _player2Controller.addListener(_validateInput);
  }

  void _validateInput() {
    setState(() {
      _isButtonEnabled = _player1Controller.text.trim().isNotEmpty &&
          _player2Controller.text.trim().isNotEmpty;
    });
  }

  void _showCustomSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.scenario.title,
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: widget.scenario.color,
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scenario Description Card with Icon
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        widget.scenario.icon,
                        color: widget.scenario.color,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.scenario.description,
                          style: GoogleFonts.roboto(
                            color: Colors.deepPurple.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Player 1 Input with Enhanced Visibility
              _buildPlayerInputSection(
                controller: _player1Controller,
                labelText: 'Player 1 Name',
                side: _player1Side,
                backgroundColor: Colors.blue.shade50,
                onSideChanged: (value) {
                  setState(() {
                    _player1Side = value!;
                    _player2Side = value == 'Heads' ? 'Tails' : 'Heads';
                  });
                },
              ),

              const SizedBox(height: 16),

              // Player 2 Input with Enhanced Visibility
              _buildPlayerInputSection(
                controller: _player2Controller,
                labelText: 'Player 2 Name',
                side: _player2Side,
                backgroundColor: Colors.red.shade50,
                isReadOnly: true,
              ),

              const SizedBox(height: 24),

              // Confirm Button with Dynamic State
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isButtonEnabled
                        ? [widget.scenario.color, widget.scenario.color.withOpacity(0.7)]
                        : [Colors.grey.shade400, Colors.grey.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: _isButtonEnabled
                          ? widget.scenario.color.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isButtonEnabled
                      ? () {
                          // Validate names are different
                          if (_player1Controller.text.trim() ==
                              _player2Controller.text.trim()) {
                            _showCustomSnackBar(
                              context,
                              'Players must have different names!',
                            );
                            return;
                          }

                          // Return scenario details
                          Navigator.of(context).pop({
                            'scenario': widget.scenario,
                            'player1': _player1Controller.text.trim(),
                            'player1Side': _player1Side,
                            'player2': _player2Controller.text.trim(),
                            'player2Side': _player2Side,
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Confirm Scenario',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build player input sections
  Widget _buildPlayerInputSection({
    required TextEditingController controller,
    required String labelText,
    required String side,
    required Color backgroundColor,
    bool isReadOnly = false,
    Function(String?)? onSideChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(
                Icons.person_outline,
                color: labelText.contains('1') 
                  ? Colors.blue.shade300 
                  : Colors.red.shade300,
              ),
            ),
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Side: ', 
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              isReadOnly
                ? Text(
                    side,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: side == 'Heads' 
                        ? Colors.green.shade700 
                        : Colors.red.shade700,
                    ),
                  )
                : DropdownButton<String>(
                    value: side,
                    dropdownColor: Colors.white,
                    items: ['Heads', 'Tails']
                        .map((sideOption) => DropdownMenuItem(
                              value: sideOption,
                              child: Text(
                                sideOption,
                                style: GoogleFonts.roboto(
                                  color: sideOption == 'Heads' 
                                    ? Colors.green.shade700 
                                    : Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: onSideChanged,
                  ),
          ],
        ),],
      ),
    );
  }

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }
}

// Updated Scenarios List
class ScenarioList {
  static List<Scenario> getScenarios() {
    return [
      Scenario(
        title: 'Who Pays the Bill?',
        description: 'Settle the bill dispute with a coin toss. Winner chooses!',
        icon: Icons.receipt_long,
        color: Colors.green,
      ),
      Scenario(
        title: 'Cricket Toss',
        description: 'Determine batting or fielding with a fair coin flip.',
        icon: Icons.sports_cricket,
        color: Colors.blue,
      ),
      Scenario(
        title: 'First Pick or Last Pick',
        description: 'Let chance decide the picking order.',
        icon: Icons.how_to_vote,
        color: Colors.orange,
      ),
      Scenario(
        title: 'Random Decision',
        description: 'When choices seem equal, let luck decide.',
        icon: Icons.shuffle,
        color: Colors.purple,
      ),
      Scenario(
        title: 'Adventure or Relaxation',
        description: 'Break the indecision with a simple coin toss.',
        icon: Icons.travel_explore,
        color: Colors.teal,
      ),
    ];
  }
}