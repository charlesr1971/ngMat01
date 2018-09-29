import { Injectable, OnInit, OnDestroy } from '@angular/core';
import { Subject } from 'rxjs/Subject';
import { Observable } from 'rxjs';
import { HttpClient, HttpHeaders } from '@angular/common/http';

import { environment } from '../../../environments/environment';

@Injectable()
export class HttpService implements OnInit, OnDestroy { 
  
  subjectImagePath: Subject<any> = new Subject<any>();
  scrollCallbackData: Subject<any> = new Subject<any>();
  galleryPage: Subject<any> = new Subject<any>();

  constructor(private http: HttpClient) {

  }

  ngOnInit() {
    
  }

  fetchDirectoryTree(): Observable<any> {
    return this.http.get(environment.ajax_dir + '/tree-dynamic-category-datasource.cfm');
  }

  fetchImages(page: number = 1): Observable<any> {
    return this.http.get(environment.ajax_dir + '/tree-dynamic-images-datasource.cfm?page=' + page);
  }

  fetchPages(): Observable<any> {
    return this.http.get(environment.ajax_dir + '/tree-dynamic-pages-datasource.cfm');
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
    return this.http.post(environment.ajax_dir + '/tree-dynamic-likes-datasource.cfm', body, headers);
  }

  ngOnDestroy() {
    
  }

  
}
