import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/stores/opening_editor.store.dart';

class MessageEditorModal extends StatelessWidget {
  final OpeningEditorStore store;
  final String moveKey;

  const MessageEditorModal({super.key, required this.store, required this.moveKey});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Mensagens - $moveKey",
            style: GoogleFonts.michroma(color: Colors.cyanAccent, fontSize: 16),
          ),
          Observer(
            builder: (_) => IconButton(
              icon: const Icon(Icons.add_comment, color: Colors.cyanAccent, size: 20),
              tooltip: "Adicionar Mensagem",
              onPressed: store.addMessage,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Observer(
          builder: (_) {
            if (store.currentMessages.isEmpty) {
              return const Center(
                child: Text(
                  "Nenhuma mensagem nesta posição.",
                  style: TextStyle(color: Colors.white24, fontSize: 14),
                ),
              );
            }

            return ListView.separated(
              itemCount: store.currentMessages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: store.currentMessages[index],
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "Digite a dica aqui...",
                          hintStyle: const TextStyle(color: Colors.white24),
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) => store.updateMessage(index, val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      tooltip: "Excluir",
                      onPressed: () => store.removeMessage(index),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Fechar", style: TextStyle(color: Colors.white54)),
        ),
      ],
    );
  }
}
