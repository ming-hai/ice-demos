% **********************************************************************
% Copyright (c) 2003-2017 ZeroC, Inc. All rights reserved.
% **********************************************************************

classdef Client

    methods(Static)

        function run(communicator)
            import Demo.*;

            while true
                name = strtrim(input('Please enter your name ==> ', 's'));
                if ~isempty(name)
                    break
                end
            end

            factory = SessionFactoryPrx.checkedCast(communicator.propertyToProxy('SessionFactory.Proxy'));
            if isempty(factory)
                fprintf('invalid proxy\n');
                return;
            end

            hellos = {};
            session = factory.create(name);

            Client.menu();

            destroy = true;
            shutdown = false;

            while true
                line = input('==> ', 's');
                if isempty(line)
                    break;
                end

                switch line
                    case {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                        index = str2num(line);
                        if index < length(hellos)
                            hello = hellos{index + 1};
                            hello.sayHello();
                        else
                            fprintf('Index is too high. %i exist so far. Use "c" to create a new hello object.\n',...
                                    index);
                        end
                    case 'c'
                        hellos{ length(hellos) + 1 } = session.createHello();
                        fprintf('created hello object %i\n', length(hellos) - 1);
                    case 's'
                        destroy = false;
                        shutdown = true;
                        break;
                    case 'x'
                        break;
                    case 't'
                        destroy = false;
                        break;
                    case '?'
                        Client.menu();
                    otherwise
                        fprintf('unknown command `%s''\n', line);
                        Client.menu();
                end
            end

            if destroy
                session.destroy();
            end

            if shutdown
                factory.shutdown();
            end
        end

        function main()
            addpath('generated');
            if ~libisloaded('ice')
                loadlibrary('ice', @iceproto);
            end

            try
                % Initializes a communicator and then destroys it when cleanup is collected
                communicator = Ice.initialize({'--Ice.Config=config.client'});
                cleanup = onCleanup(@() communicator.destroy());
                Client.run(communicator);
                status = 0;
            catch ex
                fprintf('%s\n', getReport(ex));
                status = 1;
            end
        end

        function menu()
            fprintf(['usage:\n'...
                     'c:     create a new per-client hello object\n'...
                     '0-9:   send a greeting to a hello object\n'...
                     's:     shutdown the server and exit\n'...
                     'x:     exit\n'...
                     't:     exit without destroying the session\n'...
                     '?:     help\n']);
        end
    end
end
