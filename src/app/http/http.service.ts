import { Injectable, OnDestroy } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { HttpClient } from '@angular/common/http';

import { environment } from '../../environments/environment';

@Injectable()
export class HttpService implements OnDestroy {  

  constructor(private http: HttpClient) {

  }

  fetchDirectoryTree(): Observable<any> {
    return this.http.get(environment.ajax_dir + '/tree-dynamic-category-datasource.cfm').pipe(map(
      (res: Response) => {
        console.log(res);
        return res;
      })
    );
  }

  ngOnDestroy() {
    
  }

  
}
