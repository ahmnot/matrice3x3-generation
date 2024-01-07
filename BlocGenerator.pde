import controlP5.*;
import java.awt.image.BufferedImage;
import java.io.*;
import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;
import java.util.zip.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import javax.imageio.ImageIO;
import javax.swing.JFileChooser;
import javax.swing.UIManager;
import javax.swing.filechooser.FileNameExtensionFilter;
import processing.core.*;

/**
 * Ceci est un programme Processing/Java, qui génère des "blocs",
 * et permet de manipuler leur affichage grâce à une IHM,
 * l'IHM dépendant de la librairie controlP5.
 *
 * Pour utiliser ce programme, ouvrez-le avec une interface Processing, et cliquez sur le bouton "Exécuter" de Processing.
 *
 * Définition : un "bloc" est une matrice 3x3 composée de 0 ou de 1.
 * Pour visualiser ces blocs, on dit que 0 = petit carré noir et 1 = petit carré blanc.
 * L'objectif de ce code est de générer l'intégralité de ces blocs, et de les classer.
 * Pour cela, il y a possibilité d'activer des filtres sur le type de blocs affichés, grâce à l'IHM.
 * Par exemple, un bloc "continu" est un bloc dans lequel tous les "1" sont connectés, mais pas en diagonale.
 * Un bloc "brisé" est un bloc qui n'est pas continu.
 * Il y a ensuite des filtres de motifs.
 * Le programme permet enfin exporter tous les blocs affichés à l'écran, dans un fichier zip.
 * (La version p5.js est disponible sur mon Github : https://github.com/ahmnot/matrice3x3-generation
 */
public class BlocGenerator extends PApplet {

  // La première partie de ce code concerne un ensemble de fonctions utilitaires.

  /**
   * Rotationne une matrice à 90°.
   */
  int[][] rotateBlocPlus90(int[][] matrix) {
    int[][] rotatedMatrix = new int[3][3];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        rotatedMatrix[i][j] = matrix[3 - j - 1][i];
      }
    }

    return rotatedMatrix;
  }

  /**
   * Détermine l'égalité de 2 matrices.
   */
  boolean areMatricesEqual(int[][] matrix1, int[][] matrix2) {
    if (
      matrix1.length != matrix2.length || matrix1[0].length != matrix2[0].length
    ) {
      return false;
    }

    for (int i = 0; i < matrix1.length; i++) {
      for (int j = 0; j < matrix1[i].length; j++) {
        if (matrix1[i][j] != matrix2[i][j]) {
          return false;
        }
      }
    }

    return true;
  }

  /**
   * Détermine si un bloc (= une matrice) peut être obtenue par la rotation d'une autre.
   */
  boolean estRotationDe(int[][] bloc, int[][] autreBloc) {
    int[][] rotation = autreBloc;
    for (int i = 0; i < 4; i++) {
      if (areMatricesEqual(bloc, rotation)) {
        return true;
      }
      rotation = rotateBlocPlus90(rotation);
    }
    return false;
  }

  /**
   * Sert à savoir si un bloc est "équivalent par rotation" d'une liste de blocs.
   */
  boolean estEquivalentParRotation(
    int[][] bloc,
    ArrayList<int[][]> listeBlocs
  ) {
    for (int[][] autreBloc : listeBlocs) {
      if (estRotationDe(bloc, autreBloc)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Réduit, dans une liste, les blocs équivalents par rotations.
   */
  ArrayList<int[][]> filtrerBlocsParClasseDeRotation(
    ArrayList<int[][]> listeBlocs
  ) {
    ArrayList<int[][]> listeResultat = new ArrayList<>();
    for (int[][] bloc : listeBlocs) {
      if (!estEquivalentParRotation(bloc, listeResultat)) {
        listeResultat.add(bloc);
      }
    }

    return listeResultat;
  }

  /**
   * Donne la symétrie horizontale d'une matrice.
   */
  int[][] symetriserHorizontalement(int[][] matrix) {
    int[][] mirroredMatrix = new int[matrix.length][matrix[0].length];

    for (int i = 0; i < matrix.length; i++) {
      mirroredMatrix[i] = matrix[matrix.length - 1 - i];
    }

    return mirroredMatrix;
  }

  /**
   * Donne la symétrie verticale d'une matrice.
   */
  int[][] symetriserVerticalement(int[][] matrix) {
    int[][] mirroredMatrix = new int[matrix.length][matrix[0].length];

    for (int i = 0; i < matrix.length; i++) {
      for (int j = 0; j < matrix[i].length; j++) {
        mirroredMatrix[i][j] = matrix[i][matrix[i].length - 1 - j];
      }
    }

    return mirroredMatrix;
  }

  /**
   * Détermine si 2 blocs sont "équivalents par symétrie rotation".
   */
  boolean sontEquivalentParSymetrieRotation(int[][] bloc1, int[][] bloc2) {
    int[][] rotation = bloc2;
    for (int i = 0; i < 4; i++) {
      if (
        areMatricesEqual(bloc1, symetriserHorizontalement(rotation)) ||
        areMatricesEqual(bloc1, symetriserVerticalement(rotation))
      ) {
        return true;
      }
      rotation = rotateBlocPlus90(rotation);
    }
    return false;
  }

  /**
   * Réduit, dans une liste, les blocs équivalents par "symétrie rotations"
   */
  ArrayList<int[][]> filtrerBlocsParClasseDeSymetrieRotation(
    ArrayList<int[][]> listeBlocs
  ) {
    ArrayList<int[][]> listeResultat = new ArrayList<>();

    for (int[][] bloc : listeBlocs) {
      boolean estUnique = true;
      for (int[][] autreBloc : listeResultat) {
        if (sontEquivalentParSymetrieRotation(bloc, autreBloc)) {
          estUnique = false;
          break;
        }
      }
      if (estUnique) {
        listeResultat.add(bloc);
      }
    }

    return listeResultat;
  }

  /**
   * Détermine si, dans une matrice, les "1" sont "connectés" (au sens de la définition ci-dessus).
   */
  static boolean areOnesConnected(int[][] matrice) {
    int[][] directions = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } };
    int taille = matrice.length;
    boolean[][] visite = new boolean[taille][taille];
    boolean premierUnTrouve = false;

    for (int i = 0; i < taille; i++) {
      for (int j = 0; j < taille; j++) {
        if (matrice[i][j] == 1) {
          if (!premierUnTrouve) {
            explorerContinuite(i, j, visite, matrice, directions);
            premierUnTrouve = true;
          } else if (!visite[i][j]) {
            return false;
          }
        }
      }
    }
    return premierUnTrouve;
  }

  /**
   * Fonction utilitaire récursive pour le parcours d'une matrice.
   */
  static void explorerContinuite(
    int i,
    int j,
    boolean[][] visite,
    int[][] matrice,
    int[][] directions
  ) {
    if (
      i < 0 ||
      i >= matrice.length ||
      j < 0 ||
      j >= matrice[i].length ||
      visite[i][j] ||
      matrice[i][j] == 0
    ) {
      return;
    }

    visite[i][j] = true;

    for (int[] direction : directions) {
      explorerContinuite(
        i + direction[0],
        j + direction[1],
        visite,
        matrice,
        directions
      );
    }
  }

  /**
   * Renvoie true si le bloc en paramètre vérifie le "pattern 0".
   *
   * Les blocs qui respectent le pattern 0 comprennent une "version" de ceci :
   *
   * { { 0, 0, 0 }
   * , { 0, 1, 0 }
   * , { 0, 0, 0 } }
   *
   */
  boolean verifierPattern0(int[][] bloc) {
    int nombreUns = 0;
    for (int i = 0; i < bloc.length; i++) {
      for (int j = 0; j < bloc[i].length; j++) {
        if (bloc[i][j] == 1) {
          nombreUns++;
          if (nombreUns > 1) return false; // Plus de 1 '1' trouvés
          // Vérification les carrés adjacents horizontalement et verticalement
          if (
            (j < bloc[i].length - 1 && bloc[i][j + 1] == 1) ||
            (j > 0 && bloc[i][j - 1] == 1) ||
            (i < bloc.length - 1 && bloc[i + 1][j] == 1) ||
            (i > 0 && bloc[i - 1][j] == 1)
          ) {
            return true;
          }
        }
      }
    }
    return nombreUns == 1;
  }

  /**
   * Renvoie true si le bloc en paramètre vérifie le "pattern 1".
   *
   * Pattern 1 :
   *
   * { { 0, 0, 0 }
   * , { 1, 1, 0 }
   * , { 0, 0, 0 } }
   */
  boolean verifierPattern1(int[][] bloc) {
    for (int i = 0; i < bloc.length; i++) {
      for (int j = 0; j < bloc[i].length; j++) {
        if (bloc[i][j] == 1) {
          if (
            (
              i < bloc.length - 1 &&
              j < bloc[i].length - 1 &&
              bloc[i + 1][j + 1] == 1
            ) ||
            (i > 0 && j > 0 && bloc[i - 1][j - 1] == 1) ||
            (i < bloc.length - 1 && j > 0 && bloc[i + 1][j - 1] == 1) ||
            (i > 0 && j < bloc[i].length - 1 && bloc[i - 1][j + 1] == 1)
          ) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /**
   * Renvoie true si le bloc en paramètre vérifie le "pattern 2".
   *
   * Pattern 2 :
   *
   * { { 1, 0, 0 }
   * , { 0, 1, 0 }
   * , { 0, 0, 0 } }
   */
  boolean verifierPattern2(int[][] bloc) {
    for (int i = 0; i < bloc.length; i++) {
      for (int j = 0; j < bloc[i].length; j++) {
        if (bloc[i][j] == 1) {
          if (
            (j < bloc[i].length - 2 && bloc[i][j + 2] == 1) ||
            (j > 1 && bloc[i][j - 2] == 1) ||
            (i < bloc.length - 2 && bloc[i + 2][j] == 1) ||
            (i > 1 && bloc[i - 2][j] == 1)
          ) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /**
   * Renvoie true si le bloc en paramètre vérifie le "pattern 3".
   *
   * Pattern 3 :
   *
   * { { 1, 0, 0 }
   * , { 0, 0, 1 }
   * , { 0, 0, 0 } }
   *
   */
  boolean verifierPattern3(int[][] bloc) {
    ArrayList<int[]> positions = new ArrayList<>();

    for (int i = 0; i < bloc.length; i++) {
      for (int j = 0; j < bloc[i].length; j++) {
        if (bloc[i][j] == 1) {
          positions.add(new int[] { i, j });
        }
      }
    }

    for (int a = 0; a < positions.size(); a++) {
      for (int b = a + 1; b < positions.size(); b++) {
        int[] posA = positions.get(a);
        int[] posB = positions.get(b);
        if (
          posA[0] != posB[0] &&
          posA[1] != posB[1] &&
          !(posA[0] + posB[0] == 2 && posA[1] + posB[1] == 2)
        ) {
          if (
            (posA[0] == 0 && posB[0] == 2) ||
            (posA[0] == 2 && posB[0] == 0) ||
            (posA[1] == 0 && posB[1] == 2) ||
            (posA[1] == 2 && posB[1] == 0)
          ) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /**
   * Renvoie true si le bloc en paramètre vérifie le "pattern 4".
   *
   * Pattern 4 :
   *
   * { { 1, 0, 0 }
   * , { 0, 0, 0 }
   * , { 0, 0, 1 } }
   *
   */
  boolean verifierPattern4(int[][] bloc) {
    return (
      (bloc[0][0] == 1 && bloc[2][2] == 1) ||
      (bloc[0][2] == 1 && bloc[2][0] == 1)
    );
  }

  /**
   * Renvoie true si le bloc en paramètre vérifie le "pattern -1".
   *
   * Pattern -1 :
   *
   * { { 0, 0, 0 }
   * , { 0, 0, 0 }
   * , { 0, 0, 0 } }
   *
   */
  boolean verifierPatternm1(int[][] bloc) {
    int[][] patternm1 = { { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } };
    return Arrays.deepEquals(bloc, patternm1);
  }

  /**
   * Renvoie une liste de tous les nombres binaires à 9 chiffres, sous la forme d'une liste de String.
   */
  static ArrayList<String> genererBinaires9Chiffres() {
    ArrayList<String> binaires = new ArrayList<String>();
    for (int i = 0; i < 512; i++) { // 2^9 = 512
      String binaire = Integer.toBinaryString(i);
      while (binaire.length() < 9) {
        binaire = "0" + binaire; // Ajouter des zéros au début
      }
      binaires.add(binaire);
    }
    return binaires;
  }

  /**
   * Compte le nombre de "1" d'un nombre binaire.
   */
  static int compterUns(String binaire) {
    int count = 0;
    for (char caractere : binaire.toCharArray()) {
      if (caractere == '1') {
        count++;
      }
    }
    return count;
  }

  /**
   * Renvoie une liste de binaires filtrés selon leurs nombres de "1".
   */
  ArrayList<String> filtrerParNombreDeUns(
    ArrayList<String> listeBinaires,
    int nombreUns
  ) {
    ArrayList<String> resultat = new ArrayList<>();
    for (String binaire : listeBinaires) {
      if (compterUns(binaire) == nombreUns) {
        resultat.add(binaire);
      }
    }
    return resultat;
  }

  /**
   * Transforme un binaire en bloc.
   */
  static int[][] genererBloc(String binaire) {
    // Ajout préalable de 0 à la fin des binaires si besoin
    while (binaire.length() < 9) {
      binaire += "0";
    }
    int[][] bloc = new int[3][3];
    int compteur = 0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        bloc[i][j] = Character.getNumericValue(binaire.charAt(compteur));
        compteur++;
      }
    }
    return bloc;
  }

  /**
   * Transforme une liste de binaires en une liste de blocs.
   */
  static ArrayList<int[][]> genererLesBlocs(ArrayList<String> listeBinaires) {
    ArrayList<int[][]> blocsResultat = new ArrayList<>();
    for (String unBinaire : listeBinaires) {
      blocsResultat.add(genererBloc(unBinaire));
    }
    return blocsResultat;
  }

  /**
   * Sélectionne les blocs "continus".
   */
  static ArrayList<int[][]> filtrerBlocsContinus(
    ArrayList<int[][]> listeBlocs
  ) {
    ArrayList<int[][]> blocsResultat = new ArrayList<>();
    for (int[][] unBloc : listeBlocs) {
      if (areOnesConnected(unBloc)) {
        blocsResultat.add(unBloc);
      }
    }
    return blocsResultat;
  }

  /**
   * Sélectionne les blocs "brisés".
   */
  static ArrayList<int[][]> filtrerBlocsBrises(ArrayList<int[][]> listeBlocs) {
    ArrayList<int[][]> blocsResultat = new ArrayList<>();
    for (int[][] unBloc : listeBlocs) {
      if (!areOnesConnected(unBloc)) {
        blocsResultat.add(unBloc);
      }
    }
    return blocsResultat;
  }

  static ArrayList<String> tousLesBinaires = genererBinaires9Chiffres();

  // Cette deuxième partie est le code Processing, qui permet d'afficher les blocs.

  // Détermine le nombre de carrés blancs des blocs affichés.
  int nombreCarresBlancs = 5;

  // Des listes de blocs.
  ArrayList<int[][]> tousLesBlocs;
  ArrayList<int[][]> blocsContinus;
  ArrayList<int[][]> blocsBrises;
  ArrayList<int[][]> blocsAffiches;

  // Déterminent la façon dont les blocs sont alignés.
  int scaling = 15;
  int rownumber = 11;
  int elementsPerRow;
  int blockSize = 3;
  int verticalLineWidth = 1;
  int horizontalLineWidth = 2;

  int canvasWidth;
  int canvasHeight;
  int decalageHorizontal = 0;

  String stringPatternChecked = "";

  int positionIHMx = 300;
  int positionIHMy = 550;

  int minWidth = 1000;
  int minHeight = 1500;

  int totalWidth;
  int gridStartX = 0;
  int gridStartY = 0;

  int gridEndX;
  int gridEndY;

  int couleurBackground = 15;

  boolean regenererBlocs = true;

  ControlP5 cp5;
  RadioButton radioTypeBlocs;
  Toggle checkboxAfficherTout;
  Toggle[] checkboxes = new Toggle[6];
  Textlabel nombreBlocs;

  PImage exempleBlocContinu;
  PImage exempleBlocBrise;
  PImage exemplePattern01;
  PImage exemplePattern02;
  PImage exemplePattern1;
  PImage exemplePattern2;
  PImage exemplePattern3;
  PImage exemplePattern4;
  PImage exemplePatternm11;

  public static void main(String[] args) {
    PApplet.main("BlocGenerator");
  }

  /**
   * Sert à construire l'IHM, à l'aide de la bibliothèque ControlP5.
   */
  void initializeMenuBlocs() {
    cp5 = new ControlP5(this);
    Textlabel legendeFiltres;
    Button randomiserButton;
    Button exportButton;

    cp5
      .addTextlabel("tutoTexte")
      .setText("Cliquez sur un bloc pour l'exporter.")
      .setPosition(positionIHMx + 25, positionIHMy - 20);

    // Le texte de présentation
    String texte =
      "INTRODUCTION :\n\n" +
      "Le programme que vous venez d'ouvrir \nest un programme qui affiche les \"blocs\" generes ci-dessus." +
      "\n\nDefinitions :\n" +
      "- un \"bloc\" est la representation graphique d'une matrice 3x3 \nconstituee de 0 ou de 1.\n" +
      "- Un \"carre\" est la representation graphique d'un 0 ou d'un 1.\n" +
      "Un bloc est donc constitue de 9 carres.\n" +
      "Les blocs affiches, en haut a gauche, \nsont controles par les differents filtres et boutons, a gauche.\n" +
      "Vous pouvez cliquer sur un bloc pour l'exporter, \nou exporter tous les blocs affiches d'un coup.\n" +
      "Auteur : ahmnot/Othman Moatassime";

    cp5
      .addTextlabel("label")
      .setText(texte)
      .setPosition(positionIHMx + 400, positionIHMy)
      .setSize(200, 50);

    cp5
      .addSlider("sliderNombreCarres")
      .setPosition(positionIHMx + 20, positionIHMy + 50)
      .setRange(0, 9)
      .setValue(nombreCarresBlancs)
      .setSize(200, 19)
      .setCaptionLabel("Nombre de Carres Blancs dans un bloc")
      .setNumberOfTickMarks(10)
      .onChange(
        new CallbackListener() {
          public void controlEvent(CallbackEvent event) {
            onSliderChange();
          }
        }
      );

    checkboxAfficherTout =
      cp5
        .addToggle("checkboxAfficherTout")
        .setPosition(positionIHMx + 250, positionIHMy + 80)
        .setSize(20, 20)
        .setLabel("Afficher tous les blocs")
        .onChange(
          new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
              onCheckboxChange();
            }
          }
        );

    cp5
      .addToggle("checkboxRotations")
      .setPosition(positionIHMx + 20, positionIHMy + 80)
      .setSize(20, 20) // Taille de la checkbox
      .setValue(false) // Valeur initiale
      .setCaptionLabel("Enlever rotations")
      .onChange(
        new CallbackListener() {
          public void controlEvent(CallbackEvent event) {
            onCheckboxChange();
          }
        }
      );

    cp5
      .addToggle("checkboxSymetries")
      .setPosition(positionIHMx + 140, positionIHMy + 80)
      .setSize(20, 20)
      .setValue(false)
      .setCaptionLabel("Enlever symetries")
      .onChange(
        new CallbackListener() {
          public void controlEvent(CallbackEvent event) {
            onCheckboxChange();
          }
        }
      );

    cp5
      .addTextlabel("radioTypeBlocsLegende")
      .setText("Type de blocs affiches :")
      .setPosition(positionIHMx - 100, positionIHMy + 155);

    radioTypeBlocs =
      cp5
        .addRadioButton("radioTypeBlocs")
        .setPosition(positionIHMx + 20, positionIHMy + 130)
        .setSize(20, 20)
        .setColorForeground(color(120))
        .setColorActive(color(255))
        .addItem("Tous", 1)
        .addItem("Continus", 2)
        .addItem("Brises", 3);

    // Option sélectionnée par défaut
    radioTypeBlocs.activate(0);

    legendeFiltres =
      cp5
        .addTextlabel("legendeFiltres")
        .setText("Application de filtres :")
        .setPosition(positionIHMx - 100, positionIHMy + 250);

    // Création des checkboxes des filtres des patterns
    String[] labels = {
      "Pattern 0",
      "Pattern 1",
      "Pattern 2",
      "Pattern 3",
      "Pattern 4",
      "Pattern -1",
    };

    for (int i = 0; i < checkboxes.length; i++) {
      checkboxes[i] =
        cp5
          .addToggle("checkbox" + i)
          .setPosition(positionIHMx + 20, positionIHMy + 205 + 20 * i)
          .setSize(20, 20)
          .setLabel(labels[i])
          .setValue(false)
          .setId(i)
          .addListener(
            new ControlListener() {
              public void controlEvent(ControlEvent event) {
                onCheckboxPatternsChange(event);
              }
            }
          );
      checkboxes[i].getCaptionLabel()
        .align(ControlP5.LEFT, ControlP5.CENTER)
        .setPaddingX(25) // Ajuster en fonction de vos besoins
        .setText(labels[i]);
    }

    randomiserButton =
      cp5
        .addButton("randomiserBlocs")
        .setValue(0)
        .setPosition(positionIHMx + 230, positionIHMy + 250)
        .setSize(200, 19)
        .setLabel("Randomiser ordre des blocs");

    nombreBlocs =
      cp5
        .addTextlabel("nombreBlocs")
        .setText("Nombre de blocs affiches : ")
        .setPosition(positionIHMx + 40, positionIHMy + 330);

    exportButton =
      cp5
        .addButton("exportAllBlocks")
        .setPosition(positionIHMx + 30, positionIHMy + 365)
        .setSize(200, 19)
        .setLabel("Exporter tous les blocs affiches");

    exportButton.onClick(
      new CallbackListener() {
        public void controlEvent(CallbackEvent event) {
          exportAllBlocks(); // Méthode à appeler lorsque le bouton est pressé
        }
      }
    );
  }

  public void settings() {
    Collections.sort(tousLesBinaires, (a, b) -> compterUns(a) - compterUns(b));

    // Génération des blocs
    tousLesBlocs = genererLesBlocs(tousLesBinaires);
    blocsContinus = filtrerBlocsContinus(tousLesBlocs);
    blocsBrises = filtrerBlocsBrises(tousLesBlocs);

    // Inversion des listes pour des raisons d'affichage
    Collections.reverse(tousLesBlocs);
    Collections.reverse(blocsContinus);
    Collections.reverse(blocsBrises);

    blocsAffiches = new ArrayList<>(tousLesBlocs);

    elementsPerRow = (int) Math.ceil((double) tousLesBlocs.size() / rownumber);

    // Ce calcul de tailles du canvas ne fonctionnait pas,
    // je préfère donc laisser une taille fixe au canvas pour le moment

    // canvasWidth =
    //   elementsPerRow *
    //   (blockSize * scaling + verticalLineWidth) -
    //   verticalLineWidth;
    // canvasHeight = rownumber * blockSize * scaling;

    // canvasWidth = Math.max(canvasWidth, minWidth);
    // canvasHeight = Math.max(canvasHeight, minHeight);

    size(2160, 1080);
  }

  public void setup() {
    try {
      // Sert à conformer la boîte de dialogue d'export à l'OS de l'utilisateur.
      UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
    } catch (Exception e) {
      e.printStackTrace();
    }

    totalWidth = blockSize * scaling + verticalLineWidth;
    gridEndX = gridStartX + elementsPerRow * totalWidth;
    gridEndY = gridStartY + rownumber * (blockSize * scaling);

    initializeMenuBlocs();

    background(couleurBackground);
    // Les lignes suivantes sont censées charger les images situées dans le dossier "/data"
    // mais ne se chargent pas pour une raison incompréhensible.
    // L'équivalent en p5.js fonctionne.
    // Les décommenter si besoin.

    // exempleBlocContinu = loadImage("blocs-6_19.png");
    // exempleBlocBrise = loadImage("blocs-5_09.png");
    // exemplePattern01 = loadImage("blocs-2_22.png");
    // exemplePattern02 = loadImage("bloc-1-3.png");
    // exemplePattern1 = loadImage("blocs-2_04.png");
    // exemplePattern2 = loadImage("blocs-2_23.png");
    // exemplePattern3 = loadImage("blocs-2_05.png");
    // exemplePattern4 = loadImage("blocs-2_08.png");
    // exemplePatternm11 = loadImage("bloc-0.png");
  }

  public void draw() {
    if (regenererBlocs) {
      tousLesBlocs.clear();
      blocsContinus.clear();
      blocsBrises.clear();

      if (checkboxAfficherTout.getState()) {
        tousLesBlocs = genererLesBlocs(tousLesBinaires);
        // Désactivation du slider si l'utilisateur choisit d'afficher tous les blocs
        cp5.getController("sliderNombreCarres").setLock(true);
        cp5
          .getController("sliderNombreCarres")
          .setColorForeground(color(128, 128, 128, 128));
      } else {
        tousLesBlocs =
          genererLesBlocs(
            filtrerParNombreDeUns(tousLesBinaires, nombreCarresBlancs)
          );
        cp5.getController("sliderNombreCarres").setLock(false);
        cp5
          .getController("sliderNombreCarres")
          .setColorForeground(color(0, 128, 128, 255));
      }

      blocsContinus = filtrerBlocsContinus(tousLesBlocs);
      blocsBrises = filtrerBlocsBrises(tousLesBlocs);

      Collections.reverse(tousLesBlocs);
      Collections.reverse(blocsContinus);
      Collections.reverse(blocsBrises);

      boolean rotationsChecked =
        cp5.getController("checkboxRotations").getValue() == 1;

      if (rotationsChecked) {
        tousLesBlocs = filtrerBlocsParClasseDeRotation(tousLesBlocs);
        blocsContinus = filtrerBlocsParClasseDeRotation(blocsContinus);
        blocsBrises = filtrerBlocsParClasseDeRotation(blocsBrises);
      }

      // Vérification de la checkbox 'Symétries'
      boolean symetriesChecked =
        cp5.getController("checkboxSymetries").getValue() == 1;

      if (symetriesChecked) {
        tousLesBlocs = filtrerBlocsParClasseDeSymetrieRotation(tousLesBlocs);
        blocsContinus = filtrerBlocsParClasseDeSymetrieRotation(blocsContinus);
        blocsBrises = filtrerBlocsParClasseDeSymetrieRotation(blocsBrises);
      }

      int selectedRadio = (int) radioTypeBlocs.getValue();

      switch (selectedRadio) {
        case 1: // 1 est la valeur pour 'Tous'
          blocsAffiches = tousLesBlocs;
          break;
        case 2: // 2 est la valeur pour 'Continus'
          blocsAffiches = blocsContinus;
          break;
        case 3: // 3 est la valeur pour 'Brisés'
          blocsAffiches = blocsBrises;
          break;
        default:
          break;
      }

      // Filtrage des blocs affichés selon les patterns sélectionnés.
      List<int[][]> filteredList = (List<int[][]>) blocsAffiches;

      if (cp5.getController("checkbox0").getValue() == 1) {
        filteredList =
          filteredList
            .stream()
            .filter(this::verifierPattern0)
            .collect(Collectors.toList());
      }
      if (cp5.getController("checkbox1").getValue() == 1) {
        filteredList =
          filteredList
            .stream()
            .filter(this::verifierPattern1)
            .collect(Collectors.toList());
      }
      if (cp5.getController("checkbox2").getValue() == 1) {
        filteredList =
          filteredList
            .stream()
            .filter(this::verifierPattern2)
            .collect(Collectors.toList());
      }
      if (cp5.getController("checkbox3").getValue() == 1) {
        filteredList =
          filteredList
            .stream()
            .filter(this::verifierPattern3)
            .collect(Collectors.toList());
      }
      if (cp5.getController("checkbox4").getValue() == 1) {
        filteredList =
          filteredList
            .stream()
            .filter(this::verifierPattern4)
            .collect(Collectors.toList());
      }
      if (cp5.getController("checkbox5").getValue() == 1) {
        filteredList =
          filteredList
            .stream()
            .filter(this::verifierPatternm1)
            .collect(Collectors.toList());
      }

      blocsAffiches = (ArrayList<int[][]>) filteredList;

      // Mise à jour du label du nombre de blocs
      nombreBlocs.setValue(
        "Nombre de blocs affiches : " + blocsAffiches.size()
      );

      regenererBlocs = false; // Variable qui est mise à jour au clic de certains éléments de l'IHM
    }

    // Nettoyage du canvas
    background(couleurBackground);

    // Ajout des images indicatives, si elles fonctionnaient.
    // Les décommenter si besoin.

    // image(exempleBlocContinu, 383, positionIHMy + 130);
    // image(exempleBlocBrise, 447, positionIHMy + 130);
    // image(exemplePattern01, 383, positionIHMy + 175 + 12);
    // image(exemplePattern02, 403, positionIHMy + 175 + 12);
    // image(exemplePattern1, 383, positionIHMy + 175 + 32);
    // image(exemplePattern2, 383, positionIHMy + 175 + 52);
    // image(exemplePattern3, 383, positionIHMy + 175 + 72);
    // image(exemplePattern4, 383, positionIHMy + 175 + 92);
    // image(exemplePatternm11, 383, positionIHMy + 175 + 112);

    // Dessin des blocs.
    for (int l = 0; l < rownumber; l++) {
      for (int k = 0; k < elementsPerRow; k++) {
        int index = l * elementsPerRow + k;
        if (index < blocsAffiches.size()) {
          int[][] unBloc = blocsAffiches.get(index);
          for (int i = 0; i < blockSize; i++) {
            for (int j = 0; j < blockSize; j++) {
              if (unBloc[i][j] == 1) {
                fill(255); // Couleur du carré
                noStroke();
                square(
                  j * scaling + decalageHorizontal,
                  (i + l * blockSize) * scaling,
                  scaling
                );
              }
            }
          }
          decalageHorizontal += blockSize * scaling + verticalLineWidth;
        }
      }
      decalageHorizontal = 0;

      // Dessin d'une ligne horizontale après chaque ligne de blocs
      if (l < rownumber - 1) {
        stroke(couleurBackground); // Couleur de la ligne
        strokeWeight(horizontalLineWidth);
        line(
          0,
          (l + 1) * blockSize * scaling,
          canvasWidth,
          (l + 1) * blockSize * scaling
        );
      }
    }

    drawHoverSquare();
  }

  /**
   * Sert à dessiner le carré rouge au survol de la grille.
   */
  void drawHoverSquare() {
    int gridX = (int) Math.floor(mouseX / (float) totalWidth);
    int gridY = (int) Math.floor(mouseY / (float) (blockSize * scaling));

    // Vérifie si la souris est à l'intérieur du canvas
    if (
      mouseX >= gridStartX &&
      mouseX < gridEndX &&
      mouseY >= gridStartY &&
      mouseY < gridEndY
    ) {
      stroke(255, 0, 0); // Couleur de la bordure du carré de survol
      noFill();
      strokeWeight(2); // Épaisseur de la bordure
      square(
        gridX * totalWidth,
        gridY * blockSize * scaling,
        blockSize * scaling
      );
    }
  }

  // Les fonctions suivantes sont des fonctions d'écoute des évènements de changement sur les éléments de l'IHM.

  void onSliderChange() {
    nombreCarresBlancs =
      (int) cp5.getController("sliderNombreCarres").getValue();
    regenererBlocs = true;
  }

  void onCheckboxChange() {
    regenererBlocs = true;
  }

  void onCheckboxPatternsChange(ControlEvent event) {
    regenererBlocs = true;
  }

  void radioTypeBlocs(int event) {
    regenererBlocs = true;
  }

  void randomiserBlocs() {
    Collections.shuffle(blocsAffiches);
  }

  /**
   * Fonction d'export des blocs.
   */
  void exportAllBlocks() {
    JFileChooser fileChooser = new JFileChooser();
    fileChooser.setDialogTitle(
      "Choisissez un emplacement et un nom pour le fichier ZIP"
    );
    fileChooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
    FileNameExtensionFilter filter = new FileNameExtensionFilter(
      "Fichiers ZIP",
      "zip"
    );
    fileChooser.setFileFilter(filter);
    fileChooser.setSelectedFile(new File("blocs.zip")); // Nom de fichier par défaut

    int userSelection = fileChooser.showSaveDialog(null);

    if (userSelection == JFileChooser.APPROVE_OPTION) {
      File fileToSave = fileChooser.getSelectedFile();
      String filePath = fileToSave.getAbsolutePath();
      if (!filePath.toLowerCase().endsWith(".zip")) {
        filePath += ".zip";
      }
      try {
        FileOutputStream fos = new FileOutputStream(filePath);
        ZipOutputStream zos = new ZipOutputStream(fos);

        for (int index = 0; index < blocsAffiches.size(); index++) {
          PGraphics pg = createPGraphicsForBloc(blocsAffiches.get(index));

          // Conversion du PGraphics en BufferedImage
          BufferedImage bImage = new BufferedImage(
            pg.width,
            pg.height,
            BufferedImage.TYPE_INT_ARGB
          );
          for (int i = 0; i < pg.width; i++) {
            for (int j = 0; j < pg.height; j++) {
              bImage.setRGB(i, j, pg.pixels[j * pg.width + i]);
            }
          }

          // Écriture du BufferedImage dans ByteArrayOutputStream
          ByteArrayOutputStream baos = new ByteArrayOutputStream();
          ImageIO.write(bImage, "png", baos);
          byte[] imageData = baos.toByteArray();

          // Ajout au fichier ZIP
          ZipEntry entry = new ZipEntry("bloc-" + index + ".png");
          zos.putNextEntry(entry);
          zos.write(imageData);
          zos.closeEntry();
        }

        zos.close();
        fos.close();
      } catch (IOException ioe) {
        println(
          "Erreur lors de la création du fichier ZIP: " + ioe.getMessage()
        );
      }
    }
  }

  /**
   * Sert à dessiner un bloc dans un PNG.
   */
  PGraphics createPGraphicsForBloc(int[][] bloc) {
    PGraphics pg = createGraphics(blockSize * scaling, blockSize * scaling);
    pg.beginDraw();
    pg.background(0);
    pg.noFill();

    for (int i = 0; i < blockSize; i++) {
      for (int j = 0; j < blockSize; j++) {
        if (bloc[i][j] == 1) {
          pg.fill(255);
          pg.noStroke();
          pg.square(j * scaling, i * scaling, scaling);
        }
      }
    }
    pg.endDraw();
    pg.loadPixels();
    return pg;
  }
}
