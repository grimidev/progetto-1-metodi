using MatrixMarket
using SuiteSparse
using BenchmarkTools
function solveMatrix(x...)

  #Creo cellArray
  matrices = Array{Any}(8)

  #Array per i risultati
  allTimes = []
  allErrors = []
  allSizes = []
  allMems = []

  #Carico le matrici FEMLAB nel cellArray
  matrices[1] = MatrixMarket.mmread("C:\\Users\\Nico\\Dropbox\\ProgettoMETODI\\SparseMatrices-MM\\ns3Da.mtx")
  matrices[2] = MatrixMarket.mmread("C:\\Users\\Nico\\Dropbox\\ProgettoMETODI\\SparseMatrices-MM\\poisson2D.mtx")
  matrices[3] = MatrixMarket.mmread("C:\\Users\\Nico\\Dropbox\\ProgettoMETODI\\SparseMatrices-MM\\poisson3Da.mtx")
  matrices[4] = MatrixMarket.mmread("C:\\Users\\Nico\\Dropbox\\ProgettoMETODI\\SparseMatrices-MM\\poisson3Db.mtx")
  matrices[5] = MatrixMarket.mmread("C:\\Users\\Nico\\Dropbox\\ProgettoMETODI\\SparseMatrices-MM\\problem1.mtx")
  matrices[6] = MatrixMarket.mmread("C:\\Users\\Nico\\Dropbox\\ProgettoMETODI\\SparseMatrices-MM\\sme3Da.mtx")
  matrices[7] = MatrixMarket.mmread("C:\\Users\\Nico\\Dropbox\\ProgettoMETODI\\SparseMatrices-MM\\sme3Db.mtx")
  matrices[8] = MatrixMarket.mmread("C:\\Users\\Nico\\Dropbox\\ProgettoMETODI\\SparseMatrices-MM\\sme3Dc.mtx")

  #Calcola quanti parametri in input ci sono
  howManyOptional = length(x)

  #Matrici in input - se ce ne sono
  if howManyOptional>0
    inputMatrices = Array{Any}(howManyOptional)
    for ll=1 : howManyOptional
      inputMatrices[ll] = MatrixMarket.mmread(x[ll])
    end
  end

  #Codice da eseguire se ci sono matrici in input
  if (howManyOptional>0)
    (allMems, allTimes, allErrors, allSizes) = interCalc(inputMatrices, allMems, allTimes, allErrors, allSizes)
  else
    (allMems, allTimes, allErrors, allSizes) = interCalc(matrices, allMems, allTimes, allErrors, allSizes)
  end

  #Lunghezza
  if howManyOptional>0
    numDiMatrici = howManyOptional;
  else
    numDiMatrici = 8;
  end

  #Creo matrici contenti i valori dei grafici
  #Ordino anche in modo crescento rispetto alla size
  firstTime = [allSizes ; allTimes];
  firstTime = reshape(firstTime,numDiMatrici,2);
  firstTimeSor = sortrows(firstTime,by=y->(y[1]))
  firstTimeSor = reshape(firstTimeSor,numDiMatrici,2);
  #writedlm("C:\\Users\\Nico\\Dropbox\\ProgettoMETODI\\solveMatrix_Julia\\tempistiche.txt", firstTimeSor, ',');

  secondErrors = [allSizes ; allErrors];
  secondErrors = reshape(secondErrors,numDiMatrici,2);
  secondErrorsSor = sortrows(secondErrors,by=y->(y[1]))
  secondErrorsSor = reshape(secondErrorsSor,numDiMatrici,2);
  #writedlm("C:\\Users\\Nico\\Dropbox\\ProgettoMETODI\\solveMatrix_Julia\\errori.txt", secondErrorsSor, ',');

  thirdRAM = [allSizes ; allMems];
  thirdRAM = reshape(thirdRAM,numDiMatrici,2);
  thirdRAMSor = sortrows(thirdRAM,by=y->(y[1]));
  thirdRAMSor = reshape(thirdRAMSor,numDiMatrici,2);
  #writedlm("C:\\Users\\Nico\\Dropbox\\ProgettoMETODI\\solveMatrix_Julia\\allocatedBytes.txt", thirdRAMSor, ',');

  return firstTimeSor, secondErrorsSor, thirdRAMSor;

end










function interCalc(matrices, allMems, allTimes, allErrors, allSizes)
   for o=1 : size(matrices,1)
    gc(); workspace();
    tic();

    #Salvo la soluzione esatta xe del sistema
    xe = ones(size(matrices[o],1));

    #Calcolo del right hand side
    b = matrices[o]*xe;

    #Risoluzione
    profiling = @timed(matrices[o]\b);
    profiling = profiling[3];
    x = matrices[o]\b;
    print(size(matrices[o],1));
    print("fatto\n");

    #Errore relativo
    errRel = norm(x-xe)/norm(xe);

    #Salvo dati utili
    elapsed = toc();
    allTimes = [allTimes ; elapsed];
    allSizes = [allSizes ; size(matrices[o],1)];
    allErrors = [allErrors ; errRel];
    #allMems = [allMems];
    allMems = [allMems ; profiling];


  end

  return allMems, allTimes, allErrors, allSizes;

end
