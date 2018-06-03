using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libsuitesparseconfig"], :suitesparseconfig),
    LibraryProduct(prefix, String["libamd"], :amd),
    LibraryProduct(prefix, String["libbtf"], :btf),
    LibraryProduct(prefix, String["libcamd"], :camd),
    LibraryProduct(prefix, String["libccolamd"], :ccolamd),
    LibraryProduct(prefix, String["libcolamd"], :colamd),
    LibraryProduct(prefix, String["libcholmod"], :cholmod),
    LibraryProduct(prefix, String["libldl"], :ldl),
    LibraryProduct(prefix, String["libklu"], :klu),
    LibraryProduct(prefix, String["libumfpack"], :umfpack),
    LibraryProduct(prefix, String["librbio"], :rbio),
    LibraryProduct(prefix, String["libspqr"], :spqr),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaLinearAlgebra/SuiteSparseBuilder/releases/download/v5.2.0-0.2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/SuiteSparse.aarch64-linux-gnu.tar.gz", "e0abcd3098235c30ffa928dec5e6fc5f4a55e5395f8fe75a3200b9cd8e373a00"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/SuiteSparse.arm-linux-gnueabihf.tar.gz", "20aef2086b2c519d60fcf2b942e899fe62a8e14bbcb28a6f4cf2f839860cc6a6"),
    Linux(:i686, :glibc) => ("$bin_prefix/SuiteSparse.i686-linux-gnu.tar.gz", "6916cee62e66d778159f40ee41d35814e6653e23a19aca3607de57f9b423ca46"),
    Windows(:i686) => ("$bin_prefix/SuiteSparse.i686-w64-mingw32.tar.gz", "f01b2e461fd884e9038f468a16ee909934bacf209e50b22e2893edfba7fa9882"),
    MacOS(:x86_64) => ("$bin_prefix/SuiteSparse.x86_64-apple-darwin14.tar.gz", "6d73048e8936049dc779739a5697bffcdadceefbb7fbdfe65953bc1f4bdfa3cf"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/SuiteSparse.x86_64-linux-gnu.tar.gz", "ab2a1918917a6dc84c64d302579e744520138375ad6337d485a1014c48a42c36"),
    Windows(:x86_64) => ("$bin_prefix/SuiteSparse.x86_64-w64-mingw32.tar.gz", "0655cf0fe06355e53c32694154fee1762c849fd60a93a9c49c82f996617bd150"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
