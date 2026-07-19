/// Oeffentlicher Ed25519-Schluessel zur Pruefung von Zeitexa-Lizenzen.
///
/// Das Gegenstueck (der PRIVATE Schluessel) liegt ausschliesslich lokal beim
/// Entwickler im Ordner tools/lizenz_generator/schluessel/ und wird niemals
/// committet. Dieser oeffentliche Schluessel darf dagegen bedenkenlos in der
/// App enthalten sein - er kann nur PRUEFEN, nicht ERZEUGEN.
///
/// EIGENES Schluesselpaar, unabhaengig von der Firmenversion Zeitrax:
/// Zeitrax-Lizenzen sind damit in Zeitexa ungueltig und umgekehrt.
///
/// Erzeugt am 2026-07-19 mit:
///   dart run tools/lizenz_generator/bin/lizenz_generator.dart keygen
const List<int> oeffentlicherSchluesselBytes = [
  191, 116, 123, 99, 140, 85, 73, 236, 14, 102, 212, 222, 189, 52, 104, 45,
  115, 232, 204, 121, 240, 74, 177, 126, 101, 49, 224, 182, 161, 94, 4, 21,
];
