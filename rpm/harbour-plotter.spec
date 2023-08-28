Name:       harbour-plotter

# >> macros
%define _binary_payload w2.xzdio
%define __provides_exclude_from ^%{_datadir}/%{name}/lib/.*\\.so\\>
%define __requires_exclude_from ^%{_datadir}/%{name}/lib/.*\\.so\\>
# << macros

Summary:    Plotter
Version:    0.1.1
Release:    1
License:    GPLv3
BuildArch:  noarch
URL:        http://github.com/poetaster/Plotter
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   libsailfishapp-launcher
%if "%{?vendor}" == "chum"
BuildRequires:  qt5-qttools-linguist
%endif
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.3
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
Plotter is a simple function graph plotting app in QT/QML using d3.

%if "%{?vendor}" == "chum"
PackageName: Plotter
Type: desktop-application
Categories:
 - Science
 - Utility
DeveloperName: Mark Washeim (poetaster)
Custom:
 - Repo: https://github.com/github.com/poetaster/Plotter
Icon: https://raw.github.com/poetaster/Plotter/main/icons/172x172/harbour-plotter.png
Screenshots:
 - https://raw.githubusercontent.com/poetaster/Plotter/main/Screenshot-001.png
 - https://raw.githubusercontent.com/poetaster/Plotter/main/Screenshot-002.png
 - https://raw.githubusercontent.com/poetaster/Plotter/main/Screenshot-003.png
Url:
  Donation: https://www.paypal.me/poetasterFOSS
%endif

%prep
%setup -q -n %{name}-%{version}

%build

%qmake5 

%make_build


%install
%qmake5_install


desktop-file-install --delete-original \
        --dir %{buildroot}%{_datadir}/applications \
        %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%defattr(0644,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
