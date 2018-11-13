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

RUN git clone --depth 1 -b v${VERSION} https://github.com/neo-project/neo-cli.git \
	&& cd neo-cli \
	&& dotnet restore \
	&& dotnet publish -c Release

CMD ["dotnet", "neo-cli/neo-cli/bin/Release/netcoreapp2.0/neo-cli.dll", "/rpc"]
