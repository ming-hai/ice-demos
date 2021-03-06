% **********************************************************************
% Copyright (c) 2003-2017 ZeroC, Inc. All rights reserved.
% **********************************************************************

classdef Client

    methods(Static)

        function run(communicator)
            import Demo.*;

            matrix = MatrixPrx.checkedCast(communicator.propertyToProxy('Matrix.Proxy'));
            if isempty(matrix)
                fprintf('invalid proxy\n');
                return;
            end

            % Fetch a matrix from the server
            matrixData = matrix.fetchData();

            % Convert the data into a matlab matrix
            if(matrixData.type == Demo.MatrixType.ColumnMajor)
                data = reshape(matrixData.elements, matrixData.axisLength, []);
            elseif(matrixData.type == Demo.MatrixType.RowMajor)
                % .' is shorthand for the transpose
                data = reshape(matrixData.elements, matrixData.axisLength, []).';
            end

            % Print out the dimensions and elements of the matrix
            [w, h] = size(data);
            fprintf('Received %d by %d matrix:\n', w, h);
            disp(data);

            % Compute some properties of the matrix
            sumValue = sum(data(:));
            fprintf('sum: %f\n', sumValue);
            meanValue = mean(data(:));
            fprintf('average: %f\n', meanValue);
            stdValue = std(data(:));
            fprintf('standard deviation: %f\n', stdValue);

        end

        function status = main()
            addpath('generated');
            if ~libisloaded('ice')
                loadlibrary('ice', @iceproto);
            end

            try
                %Initializes a communicator and then destroys it when cleanup is collected
                communicator = Ice.initialize({'--Ice.Config=config.client'});
                cleanup = onCleanup(@() communicator.destroy());
                Client.run(communicator);
                status = 0;
            catch ex
                fprintf('%s\n', getReport(ex));
                status = 1;
            end
        end
    end
end
