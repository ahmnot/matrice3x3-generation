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

// Le format des blocs : int[][] testMatrix = { {1, 1, 1}, {1, 1, 0}, {0, 0, 0} };

public class BlocGenerator extends PApplet {

  int[][] rotateBlocPlus90(int[][] matrix) {
    int[][] rotatedMatrix = new int[3][3];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        rotatedMatrix[i][j] = matrix[3 - j - 1][i];
      }
    }

    return rotatedMatrix;
  }

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

  boolean estEquivalentParRotation(int[][] bloc, ArrayList<int[][]> liste) {
    for (int[][] autreBloc : liste) {
      if (estRotationDe(bloc, autreBloc)) {
        return true;
      }
    }
    return false;
  }

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

  int[][] symetriserHorizontalement(int[][] matrix) {
    int[][] mirroredMatrix = new int[matrix.length][matrix[0].length];

    for (int i = 0; i < matrix.length; i++) {
      mirroredMatrix[i] = matrix[matrix.length - 1 - i];
    }

    return mirroredMatrix;
  }

  int[][] symetriserVerticalement(int[][] matrix) {
    int[][] mirroredMatrix = new int[matrix.length][matrix[0].length];

    for (int i = 0; i < matrix.length; i++) {
      for (int j = 0; j < matrix[i].length; j++) {
        mirroredMatrix[i][j] = matrix[i][matrix[i].length - 1 - j];
      }
    }

    return mirroredMatrix;
  }

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

  boolean verifierPattern0(int[][] bloc) {
    int nombreUns = 0;
    for (int i = 0; i < bloc.length; i++) {
      for (int j = 0; j < bloc[i].length; j++) {
        if (bloc[i][j] == 1) {
          nombreUns++;
          if (nombreUns > 1) return false; // Plus de 1 '1' trouvés
          // Vérifier les carrés adjacents horizontalement et verticalement
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

  boolean verifierPattern4(int[][] bloc) {
    return (
      (bloc[0][0] == 1 && bloc[2][2] == 1) ||
      (bloc[0][2] == 1 && bloc[2][0] == 1)
    );
  }

  boolean verifierPatternm1(int[][] bloc) {
    int[][] patternm1 = { { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } };
    return Arrays.deepEquals(bloc, patternm1);
  }

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

  static int compterUns(String binaire) {
    int count = 0;
    for (char caractere : binaire.toCharArray()) {
      if (caractere == '1') {
        count++;
      }
    }
    return count;
  }

  void shuffleArray(ArrayList<String> array) {
    Random rand = new Random();
    for (int i = array.size() - 1; i > 0; i--) {
      int j = rand.nextInt(i + 1);
      String temp = array.get(i);
      array.set(i, array.get(j));
      array.set(j, temp);
    }
  }

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

  static ArrayList<int[][]> genererLesBlocs(ArrayList<String> listeBinaires) {
    ArrayList<int[][]> blocsResultat = new ArrayList<>();
    for (String unBinaire : listeBinaires) {
      blocsResultat.add(genererBloc(unBinaire));
    }
    return blocsResultat;
  }

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

  static ArrayList<int[][]> filtrerBlocsBrises(ArrayList<int[][]> listeBlocs) {
    ArrayList<int[][]> blocsResultat = new ArrayList<>();
    for (int[][] unBloc : listeBlocs) {
      if (!areOnesConnected(unBloc)) {
        blocsResultat.add(unBloc);
      }
    }
    return blocsResultat;
  }

  // Appel de la fonction
  static ArrayList<String> tousLesBinaires = genererBinaires9Chiffres();

  int nombreCarresBlancs = 5;
  ArrayList<int[][]> tousLesBlocs;
  ArrayList<int[][]> blocsContinus;
  ArrayList<int[][]> blocsBrises;
  ArrayList<int[][]> blocsAffiches;

  int scaling = 15;
  int rownumber = 11;
  int elementsPerRow;
  int squareSize = 3;
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

  void initializeMenuBlocs() {
    cp5 = new ControlP5(this);
    Textlabel legendeFiltres;
    Button randomiserButton;
    Button exportButton;

    cp5
      .addTextlabel("tutoTexte")
      .setText("Cliquez sur un bloc pour l'exporter.")
      .setPosition(positionIHMx + 25, positionIHMy - 20);
    // Initialisation du texte de présentation
    String texte =
      "INTRODUCTION :\n\n" +
      "Le programme que vous venez d'ouvrir \nest un programme qui genere les \"blocs\" ci-dessus." +
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

    // Checkbox pour "Enlever rotations"
    cp5
      .addToggle("checkboxRotations")
      .setPosition(positionIHMx + 20, positionIHMy + 80)
      .setSize(20, 20) // Taille du toggle
      .setValue(false) // Valeur initiale
      .setCaptionLabel("Enlever rotations")
      .onChange(
        new CallbackListener() {
          public void controlEvent(CallbackEvent event) {
            onCheckboxChange();
          }
        }
      );

    // Checkbox pour "Enlever symétries"
    cp5
      .addToggle("checkboxSymetries")
      .setPosition(positionIHMx + 140, positionIHMy + 80)
      .setSize(20, 20) // Taille du toggle
      .setValue(false) // Valeur initiale
      .setCaptionLabel("Enlever symetries")
      .onChange(
        new CallbackListener() {
          public void controlEvent(CallbackEvent event) {
            onCheckboxChange();
          }
        }
      );

    // Créer et positionner une légende pour les boutons radio
    cp5
      .addTextlabel("radioTypeBlocsLegende")
      .setText("Type de blocs affiches :")
      .setPosition(positionIHMx - 100, positionIHMy + 155);

    // Créer les boutons radio
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

    // Définir l'option par défaut
    radioTypeBlocs.activate(0);

    // Créer la légende pour les filtres
    legendeFiltres =
      cp5
        .addTextlabel("legendeFiltres")
        .setText("Application de filtres :")
        .setPosition(positionIHMx - 100, positionIHMy + 250);

    // Créer les checkboxes
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

      // Définir l'étiquette et ajuster sa position
      checkboxes[i].getCaptionLabel()
        .align(ControlP5.LEFT, ControlP5.CENTER)
        .setPaddingX(25) // Ajuster en fonction de vos besoins
        .setText(labels[i]);
    }

    // Créer le bouton pour randomiser les blocs
    randomiserButton =
      cp5
        .addButton("randomiserBlocs")
        .setValue(0)
        .setPosition(positionIHMx + 230, positionIHMy + 250)
        .setSize(200, 19)
        .setLabel("Randomiser ordre des blocs");

    // Créer le texte pour le nombre de blocs affichés
    nombreBlocs =
      cp5
        .addTextlabel("nombreBlocs")
        .setText("Nombre de blocs affiches : ")
        .setPosition(positionIHMx + 40, positionIHMy + 330);

    // Créer le bouton pour exporter les blocs
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

  public static void main(String[] args) {
    PApplet.main("BlocGenerator");
  }

  public void settings() {
    Collections.sort(tousLesBinaires, (a, b) -> compterUns(a) - compterUns(b));
    // Génération des blocs
    tousLesBlocs = genererLesBlocs(tousLesBinaires);
    blocsContinus = filtrerBlocsContinus(tousLesBlocs);
    blocsBrises = filtrerBlocsBrises(tousLesBlocs);

    // Inverser les listes pour des raisons d'affichage
    Collections.reverse(tousLesBlocs);
    Collections.reverse(blocsContinus);
    Collections.reverse(blocsBrises);

    blocsAffiches = new ArrayList<>(tousLesBlocs); // Copie de tousLesBlocs

    elementsPerRow = (int) Math.ceil((double) tousLesBlocs.size() / rownumber);

    canvasWidth =
      elementsPerRow *
      (squareSize * scaling + verticalLineWidth) -
      verticalLineWidth;
    canvasHeight = rownumber * squareSize * scaling;

    canvasWidth = Math.max(canvasWidth, minWidth);
    canvasHeight = Math.max(canvasHeight, minHeight);

    size(canvasHeight, canvasWidth);
  }

  public void setup() {
    // Sert à conformer la boîte de dialogue d'export à l'OS de l'utilisateur.
    try {
      UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
    } catch (Exception e) {
      e.printStackTrace();
    }

    totalWidth = squareSize * scaling + verticalLineWidth;
    gridEndX = gridStartX + elementsPerRow * totalWidth;
    gridEndY = gridStartY + rownumber * (squareSize * scaling);

    initializeMenuBlocs();

    background(couleurBackground);
  }

  public void draw() {
    if (regenererBlocs) {
      tousLesBlocs.clear();
      blocsContinus.clear();
      blocsBrises.clear();

      if (checkboxAfficherTout.getState()) {
        tousLesBlocs = genererLesBlocs(tousLesBinaires);
        // Désactiver le slider si tous les blocs sont affichés
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

      // Vérifier si la checkbox 'Symétries' est cochée
      boolean symetriesChecked =
        cp5.getController("checkboxSymetries").getValue() == 1;

      if (symetriesChecked) {
        tousLesBlocs = filtrerBlocsParClasseDeSymetrieRotation(tousLesBlocs);
        blocsContinus = filtrerBlocsParClasseDeSymetrieRotation(blocsContinus);
        blocsBrises = filtrerBlocsParClasseDeSymetrieRotation(blocsBrises);
      }

      int selectedRadio = (int) radioTypeBlocs.getValue();

      switch (selectedRadio) {
        case 1: // Supposons que 1 est la valeur pour 'Tous'
          blocsAffiches = tousLesBlocs;
          break;
        case 2: // Supposons que 2 est la valeur pour 'Continus'
          blocsAffiches = blocsContinus;
          break;
        case 3: // Supposons que 3 est la valeur pour 'Brisés'
          blocsAffiches = blocsBrises;
          break;
        default:
          break;
      }

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

      // Mettre à jour le label du nombre de blocs
      nombreBlocs.setValue(
        "Nombre de blocs affichés : " + blocsAffiches.size()
      );

      // Calculer le nombre d'éléments par ligne
      int elementsPerRow = (int) Math.ceil(
        (double) blocsAffiches.size() / rownumber
      );

      // Calculer la largeur et la hauteur du canvas
      int canvasWidth =
        elementsPerRow *
        (squareSize * scaling + verticalLineWidth) -
        verticalLineWidth;
      int canvasHeight = rownumber * squareSize * scaling;

      // Assurer que le canvas n'est pas plus petit que les dimensions minimales
      canvasWidth = Math.max(canvasWidth, minWidth);
      canvasHeight = Math.max(canvasHeight, minHeight);

      // Redimensionner le canvas
      surface.setSize(canvasHeight, canvasWidth);

      regenererBlocs = false; // Réinitialiser la variable après la régénération
    }

    // Nettoyage du canvas
    background(couleurBackground);

    for (int l = 0; l < rownumber; l++) {
      for (int k = 0; k < elementsPerRow; k++) {
        int index = l * elementsPerRow + k;
        if (index < blocsAffiches.size()) {
          int[][] unBloc = blocsAffiches.get(index);
          for (int i = 0; i < squareSize; i++) {
            for (int j = 0; j < squareSize; j++) {
              if (unBloc[i][j] == 1) {
                fill(255); // Couleur du carré
                noStroke();
                square(
                  j * scaling + decalageHorizontal,
                  i * scaling + l * squareSize * scaling,
                  scaling
                );
              }
            }
          }
          decalageHorizontal += squareSize * scaling + verticalLineWidth;
        }
      }
      decalageHorizontal = 0; // Réinitialiser le décalage pour chaque ligne

      // Dessiner la ligne horizontale après chaque ligne de blocs
      if (l < rownumber - 1) {
        stroke(couleurBackground); // Couleur de la ligne
        strokeWeight(horizontalLineWidth);
        line(
          0,
          (l + 1) * squareSize * scaling,
          canvasWidth,
          (l + 1) * squareSize * scaling
        );
      }
    }

    drawHoverSquare();
  }

  void drawHoverSquare() {
    int gridX = (int) Math.floor(mouseX / (float) totalWidth);
    int gridY = (int) Math.floor(mouseY / (float) (squareSize * scaling));

    // Vérifier si la souris est à l'intérieur du canvas
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
        gridY * squareSize * scaling,
        squareSize * scaling
      );
    }
  }

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
      // Assurez-vous que le chemin du fichier se termine par ".zip"
      if (!filePath.toLowerCase().endsWith(".zip")) {
        filePath += ".zip";
      }
      try {
        FileOutputStream fos = new FileOutputStream(filePath);
        ZipOutputStream zos = new ZipOutputStream(fos);

        for (int index = 0; index < blocsAffiches.size(); index++) {
          PGraphics pg = createPGraphicsForBloc(blocsAffiches.get(index));

          // Convertir PGraphics en BufferedImage
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

          // Écrire BufferedImage dans ByteArrayOutputStream
          ByteArrayOutputStream baos = new ByteArrayOutputStream();
          ImageIO.write(bImage, "png", baos);
          byte[] imageData = baos.toByteArray();

          // Ajouter au fichier ZIP
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

  PGraphics createPGraphicsForBloc(int[][] bloc) {
    PGraphics pg = createGraphics(squareSize * scaling, squareSize * scaling);
    pg.beginDraw();
    pg.background(0);
    pg.noFill();

    for (int i = 0; i < squareSize; i++) {
      for (int j = 0; j < squareSize; j++) {
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