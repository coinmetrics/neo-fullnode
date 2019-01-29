FROM microsoft/dotnet:sdk

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libsqlite3-dev \
		libleveldb-dev \
		libunwind-dev \
		unzip \
		git \
	; \
	rm -rf /var/lib/apt/lists/*;

RUN useradd -m -u 1000 -s /bin/bash runner
USER runner
WORKDIR /home/runner

ARG VERSION

RUN set -ex; \
	git clone --depth 1 -b v${VERSION} https://github.com/neo-project/neo-cli.git; \
	cd neo-cli; \
	dotnet publish -c Release

RUN set -ex; \
	git clone --depth 1 -b v${VERSION} https://github.com/neo-project/neo-plugins.git; \
	cd neo-plugins; \
	dotnet publish -f netstandard2.0 -c Release ImportBlocks; \
	mv ImportBlocks/bin/Release/netstandard2.0 ../neo-cli/neo-cli/bin/Release/netcoreapp2.1/Plugins

COPY config.json neo-cli/neo-cli/bin/Release/netcoreapp2.1/config.json

CMD ["dotnet", "neo-cli/neo-cli/bin/Release/netcoreapp2.1/neo-cli.dll", "/rpc"]
