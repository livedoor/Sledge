package Sledge::Exceptions;
# $Id: Exceptions.pm,v 1.2 2004/02/24 12:38:29 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use Sledge::Exception;

# Concrete exceptions
package Sledge::Exception::AbstractMethod;
use base 'Sledge::Exception';
sub description { 'This method is abstract' }

package Sledge::Exception::UnimplementedMethod;
use base 'Sledge::Exception';
sub description { 'This method is unimplemented' }

package Sledge::Exception::DeprecatedMethod;
use base 'Sledge::Exception';
sub description { 'This method is now deprecated' }

package Sledge::Exception::ArgumentTypeError;
use base 'Sledge::Exception';
sub description { 'Argument type mismatch' }

package Sledge::Exception::ParamMethodUnimplemented;
use base 'Sledge::Exception';
sub description { 'Object does not implement param() method' }

package Sledge::Exception::TemplateNotFound;
use base 'Sledge::Exception';
sub description { 'Template cannot open template file' }

package Sledge::Exception::DBConnectionError;
use base 'Sledge::Exception';
sub description { 'DBI connect error' }

package Sledge::Exception::SessionIdNotFound;
use base 'Sledge::Exception';
sub description { 'Session ID is not found in DB' }

package Sledge::Exception::TemplateParseError;
use base 'Sledge::Exception';
sub description { 'TT parse error' }

package Sledge::Exception::ClassUndefined;
use base 'Sledge::Exception';
sub description { 'Pages class not defined' }

package Sledge::Exception::NoContextRunning;
use base 'Sledge::Exception';
sub description { 'No Pages context is running' }

# experimental/Sledgex-Plugin-TemplateInheritor
package Sledge::Exception::TemplatePathError;
use base 'Sledge::Exception';
sub description { 'TMPL_PATH should be absolute' }

# plugin/Sledge-Session-StrictParam
package Sledge::Exception::InvalidSessionParameter;
use base 'Sledge::Exception';
sub description { 'Session parameter is not registerd' }

# experimental/Sledgex-Plugin-MessageResources
package Sledge::Exception::ConfigKeyUndefined;
use base 'Sledge::Exception';
sub description { 'Mandatory config key is not defined' }

package Sledge::Exception::ResourceFileNotFound;
use base 'Sledge::Exception';
sub description { 'MessageResource file not found' }

# plugin/Sledge-MapDispatcher
package Sledge::Exception::PropertiesNotFound;
use base 'Sledge::Exception';
sub description { 'Properties file not found' }

package Sledge::Exception::MapFileUndefined;
use base 'Sledge::Exception';
sub description { 'should add PerlSetVar SledgeMapFile' }

# plugin/Sledge-SessionManager-CookieStore
package Sledge::Exception::StorableSigMismatch;
use base 'Sledge::Exception';
sub description { 'Storable binary image mismatch' }

# Sledge::Session::DBIFactory
package Sledge::Exception::NoDriverName;
use base 'Sledge::Exception';
sub description { 'No driver match in DATASOURCE' }

package Sledge::Exception::SessionBindClassError;
use base 'Sledge::Exception';
sub description { 'No Session implementation for Driver' }

package Sledge::Exception::LoadingModuleError;
use base 'Sledge::Exception';
sub description { 'Error while loading module' }


1;
