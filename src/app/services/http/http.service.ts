import { Injectable, OnDestroy } from '@angular/core';
import { Subject } from 'rxjs/Subject';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';

import { environment } from '../../../environments/environment';

@Injectable()
export class HttpService implements OnDestroy { 
  
  subjectImagePath: Subject<any> = new Subject<any>();

  constructor(private http: HttpClient) {

  }

  fetchDirectoryTree(): Observable<any> {
    return this.http.get(environment.ajax_dir + '/tree-dynamic-category-datasource.cfm').pipe(map(
      (res: Response) => {
        console.log("fetchDirectoryTree(): res: ",res);
        return res;
      })
    );
  }

  fetchImages(): Observable<any> {
    return this.http.get(environment.ajax_dir + '/tree-dynamic-images-datasource.cfm').pipe(map(
      (res: Response) => {
        console.log("fetchImages(): res: ",res);
        return res;
      })
    );
  }

  fetchLikes(id: any, add: any = 0, userToken: string = '', allowMultipleLikesPerUser: number = 0): Observable<any> {
    const body = {
      id: id,
      add: add,
      userToken: userToken,
      allowMultipleLikesPerUser: allowMultipleLikesPerUser
    };
    const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
    const headers = {
      headers: requestHeaders
    };
    return this.http.post(environment.ajax_dir + '/tree-dynamic-likes-datasource.cfm', body, headers).pipe(map(
      (res: Response) => {
        console.log("fetchLikes(): res: ",res);
        return res;
      })
    );
  }

  ngOnDestroy() {
    
  }

  
}
