// This is the test for the status change of the report made by the municipality.

import 'package:civiconnect/utils/report_status_priority.dart';
import 'package:mockito/annotations.dart';


/// Test Case for Modifica Stato Segnalazione
///
///
/// TC_7.0.1 invalid StatusReport Expected: changeStatus Fails
/// TC_7.0.2 StatusReport Scartata Expected: changeStatus Fails
/// TC_7.0.3 StatusReport current After new Expected: changeStatus Fails
/// TC_7.0.4 StatusReport current Before new and valid Expected: changeStatus is Accepted

